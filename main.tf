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
    cidr_blocks = ["0.0.0.0/0"] # Change this to restrict access
  }
}

resource "aws_medialive_input" "rtmp_input" {
  name = "MyRTMPInput"
  type = "RTMP_PUSH"

  destinations {
    stream_name = "my-stream"
  }

  role_arn = aws_iam_role.medialive_role.arn
}