 resource "aws_lb_listener_rule" "v2_path" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 10
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_v2.arn
  }
  condition {
    path_pattern {
      values = ["/v2*"]
    }
  }
}

resource "aws_lb_listener_rule" "shadow_path" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 20
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend_shadow.arn
  }
  condition {
    path_pattern {
      values = ["/shadow*"]
    }
  }
}
