output "instance_ip" {
  value = aws_instance.web.public_ip
}

output "sns_topic_arn" {
  value = aws_sns_topic.sns_topic.arn
}
