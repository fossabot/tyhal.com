provider "aws" {
  region = "ap-southeast-2"
}

terraform {
  required_version = ">= 0.11.11"

  backend "s3" {
//    NOTE: you will need to change these to your own
    bucket = "tyhal-terraform-state"
    key = "website/tyhal.com.tfstate"
    region = "ap-southeast-2"
  }
}

resource "aws_s3_bucket" "website" {
  bucket = "${var.domain_name}"
  acl    = "public-read"
  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    project = "${var.domain_name}"
  }
}

resource "aws_route53_zone" "site" {
  name = "${var.domain_name}"
}

resource "aws_route53_record" "siteroot" {
  zone_id = "${aws_route53_zone.site.zone_id}"
  name = "${aws_route53_zone.site.name}"
  type = "A"

  alias {
    zone_id = "${aws_s3_bucket.website.hosted_zone_id}"
    name = "${var.domain_name}"
    evaluate_target_health = false
  }
}

variable "domain_name" {
  description = "The address of where the website will be hosted"
}
