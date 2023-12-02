module "acm" {
  source      = "../../../tf-modules/acm"
  zone_id     = "Z03074173HD7OUK67JFM9"
  root_domain = "examon.org"
  subdomain = "api.examon.org"
}
