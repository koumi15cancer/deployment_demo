package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
)

// Response struct for JSON
type Response struct {
	Message     string `json:"message"`
	Version     string `json:"version"`
	ServiceName string `json:"service_name"`
}

func authMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Printf("Received request: %s %s", r.Method, r.URL.Path)
		if os.Getenv("SHADOW_MODE") == "true" {
			if authHeader := r.Header.Get("Authorization"); authHeader != "" {
				r.Header.Set("Authorization", "Bearer shadow-token")
				log.Println("Shadow mode: Replaced PROD token with shadow-token")
			}
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

	// Unified /hello endpoint for canary deployment
	mux.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		response := Response{
			Message:     "Hello from " + serviceName,
			Version:     serviceVersion,
			ServiceName: serviceName,
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