provider "aws" {
  region = "ca-central-1" 
}

resource "aws_iam_role" "medialive_role" {
  name = "MediaLiveAccessRole"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "medialive.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
resource "aws_security_group" "medialive_sg" {
  name_prefix = "medialive-sg"
  description = "Security group for MediaLive RTMP input"

  ingress {
    from_port   = 1935
    to_port     = 1935
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }
}
resource "aws_medialive_input_security_group" "medialive_security" {
  whitelist_rules {
    cidr = "0.0.0.0/0" 
  }
}

resource "aws_medialive_input" "rtmp_input" {
  name          = "MyRTMPInput"
  type          = "RTMP_PUSH"
  input_security_groups = [aws_medialive_input_security_group.medialive_security.id]

  destinations {
    stream_name = "my-stream"
  }

  role_arn = aws_iam_role.medialive_role.arn
}
output "medialive_input_id" {
  description = "The ID of the MediaLive RTMP input"
  value       = aws_medialive_input.rtmp_input.id
}

output "medialive_input_arn" {
  description = "The ARN of the MediaLive RTMP input"
  value       = aws_medialive_input.rtmp_input.arn
}

output "medialive_input_destinations" {
  description = "RTMP endpoint URLs for streaming"
  value       = aws_medialive_input.rtmp_input.destinations[*]
}
