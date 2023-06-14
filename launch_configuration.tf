###################################################
############## CREATE LAUNCH TEMPLATE #############
###################################################

resource "aws_launch_template" "first_template" {
  name_prefix            = "terraform-ec2-instance"
  image_id               = "ami-0e23c576dacf2e3df"
  instance_type          = var.ec2_instance_type
  update_default_version = true
  iam_instance_profile {
    name = aws_iam_instance_profile.iam_instance_profile.name
   }
  tags = {
      Name =  var.ec2_instance_name
  }
   
  vpc_security_group_ids = [aws_security_group.allow_sec1.id]

  user_data = base64encode(
    <<-EOF
    #!/bin/bash
    amazon-linux-extras install -y nginx1
    systemctl enable nginx --now
    EOF
  )
}

###################################################
############ CREATE AUTOSCALING GROUP #############
###################################################

resource "aws_autoscaling_group" "asg-to" {
  desired_capacity   = var.number_of_instances
  max_size           = 8
  min_size           = 2
  vpc_zone_identifier = [aws_subnet.terraform_sub3.id, aws_subnet.terraform_sub4.id]
  target_group_arns = [ aws_lb_target_group.alb-target.arn ]
  launch_template {
    id      = aws_launch_template.first_template.id
    version = "$Latest"
  }
  tag {
    key = "Name"
    value = "auto-scaled-instances"
    propagate_at_launch = true
  }
}

###################################################
############# CREATE AUTOSCALE POLICY #############
###################################################

resource "aws_autoscaling_policy" "the_policy" {
  name                   = "the-auto-policy"
  cooldown               = 60
  autoscaling_group_name = aws_autoscaling_group.asg-to.name
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment = 4
}

###################################################
################ CREATE CLOUDWATCH ################
###################################################

resource "aws_cloudwatch_metric_alarm" "cloudwatch" {
  alarm_name                = "cloudwatch-scale-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = 60
  statistic                 = "Average"
  threshold                 = 80
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions = [aws_autoscaling_policy.the_policy.arn]
}


###################################################
################## ATTACH POLICY ##################
###################################################

resource "aws_autoscaling_policy" "scale_out" {
  name                   = "scale_out_policy"
  policy_type            = "SimpleScaling"
  adjustment_type        = "ChangeInCapacity"
  scaling_adjustment     = 1
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg-to.name
}
