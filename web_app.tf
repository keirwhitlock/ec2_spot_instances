resource "aws_spot_instance_request" "web_app" {
  ami               = "${var.web_app_ami}"
  instance_type     = "${var.web_app_instance_type}"
  availability_zone = "${var.web_app_az}"
  key_name          = "${aws_key_pair.keypair.id}"
  subnet_id         = "${var.web_app_subnet_id}"
  security_groups   = ["${aws_security_group.allow_general.id}"]
  count             = "${var.web_app == "on" ? var.count : 0}"

  spot_price           = "${var.spot_price}"
  wait_for_fulfillment = "${var.wait_for_fulfillment}"
  spot_type            = "${var.spot_type}"

  user_data = "${file("${path.module}/user_data.sh")}"
  iam_instance_profile = "web_app_role"

  tags {
    Name            = "webapp-${var.environment}-${format("%02d", count.index + 1)}"
    Environment     = "${var.environment}"
    Stage           = "${var.stage}"
    Charge_Code     = "${var.charge_code}"
    Application     = "Some app"
  }
}

resource "aws_ebs_volume" "web_app_volume" {
  availability_zone = "${var.web_app_availability_zone}"
  size              = 90

  tags {
    Name            = "webapp-${var.environment}-${format("%02d", count.index + 1)}"
    Environment     = "${var.environment}"
    Stage           = "${var.stage}"
    Charge_Code     = "${var.charge_code}"
    Application     = "Some app"
  }

  count = "${var.web_app == "on" ? var.count : 0}"
}

resource "aws_volume_attachment" "web_app_volume_to_web_app" {
  force_detach = true
  device_name  = "/dev/xvdf"
  volume_id    = "${element(aws_ebs_volume.web_app_volume.*.id, count.index)}"
  instance_id  = "${element(aws_spot_instance_request.web_app.*.spot_instance_id, count.index)}"
  count        = "${var.web_app == "on" ? var.count : 0}"
}
