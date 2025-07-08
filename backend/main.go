package main

import (
	"encoding/json"
	"log"
	"net"
	"net/http"
	"os"
	"strings"

	"github.com/golang-jwt/jwt/v4"
)

// Response struct for JSON
// Add fields for A/B/canary debug
// JWTSub: sub claim from JWT if present
// UserID: X-User-Id header if present
// ClientIP: detected client IP
// HashKey: (optional) hash key used for routing
type Response struct {
	Message     string `json:"message"`
	Version     string `json:"version"`
	ServiceName string `json:"service_name"`
	ClientIP    string `json:"client_ip,omitempty"`
	UserID      string `json:"user_id,omitempty"`
	JWTSub      string `json:"jwt_sub,omitempty"`
}

func getClientIP(r *http.Request) string {
	// Check X-Forwarded-For first
	xff := r.Header.Get("X-Forwarded-For")
	if xff != "" {
		// X-Forwarded-For may contain multiple IPs, use the first
		parts := strings.Split(xff, ",")
		return strings.TrimSpace(parts[0])
	}
	// Fallback to RemoteAddr
	host, _, err := net.SplitHostPort(r.RemoteAddr)
	if err == nil {
		return host
	}
	return r.RemoteAddr
}

func getJWTSub(r *http.Request) string {
	authHeader := r.Header.Get("Authorization")
	if strings.HasPrefix(authHeader, "Bearer ") {
		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		token, _, err := new(jwt.Parser).ParseUnverified(tokenString, jwt.MapClaims{})
		if err == nil {
			if claims, ok := token.Claims.(jwt.MapClaims); ok {
				if sub, ok := claims["sub"].(string); ok {
					return sub
				}
			}
		}
	}
	return ""
}

func authMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received request: %s %s", r.Method, r.URL.Path)
		if os.Getenv("SHADOW_MODE") == "true" {
			w.Header().Set("X-Shadow-Backend", "true")
		}
		next.ServeHTTP(w, r)
	})
}

func main() {
	// Get service name and version from environment variables
	serviceName := os.Getenv("SERVICE_NAME")
	if serviceName == "" {
		// Fallback to hostname if SERVICE_NAME is not set
		hostname, err := os.Hostname()
		if err != nil {
			serviceName = "unknown"
		} else {
			serviceName = hostname
		}
	}

	serviceVersion := os.Getenv("SERVICE_VERSION")
	if serviceVersion == "" {
		serviceVersion = "1.0" // Default version
	}

	// Log all environment variables for debugging
	log.Printf("Environment variables:")
	log.Printf("SERVICE_NAME=%s", os.Getenv("SERVICE_NAME"))
	log.Printf("SERVICE_VERSION=%s", os.Getenv("SERVICE_VERSION"))
	log.Printf("PORT=%s", os.Getenv("PORT"))

	// HTTP router
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		response := Response{
			Message:     "Default Page test " + serviceName,
			Version:     serviceVersion,
			ServiceName: serviceName,
		}
		log.Printf("Sending response: %+v", response)
		if err := json.NewEncoder(w).Encode(response); err != nil {
			http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		}
	})

	// Unified /hello endpoint for canary deployment
	mux.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		response := Response{
			Message:     "Hello from " + serviceName,
			Version:     serviceVersion,
			ServiceName: serviceName,
			ClientIP:    getClientIP(r),
			UserID:      r.Header.Get("X-User-Id"),
			JWTSub:      getJWTSub(r),
		}
		log.Printf("Sending response: %+v", response)
		if err := json.NewEncoder(w).Encode(response); err != nil {
			http.Error(w, "Failed to encode response", http.StatusInternalServerError)
		}
	})

	// Apply middleware
	handler := authMiddleware(mux)

	// Start server
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	log.Printf("Server starting on port %s as %s (version %s)", port, serviceName, serviceVersion)
	if err := http.ListenAndServe(":"+port, handler); err != nil {
		log.Fatal(err)
	}
}
