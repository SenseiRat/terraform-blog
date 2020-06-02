# DNS Records
# https://www.terraform.io/docs/providers/cloudflare/r/record.html
resource "cloudflare_record" "sensei_rat" {
  zone_id = lookup(data.cloudflare_zones.sensei_rat.zones[0], "id")
  name    = "@"
  type    = "A"
  value   = aws_instance.sensei_ec2.public_ip
  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "sensei_dub" {
  zone_id = lookup(data.cloudflare_zones.sensei_rat.zones[0], "id")
  name    = "www"
  type    = "CNAME"
  value   = var.domain_name
  ttl     = 1
  proxied = true
}

# Firewall rule for Geoblocking
# https://www.terraform.io/docs/providers/cloudflare/r/filter.html
resource "cloudflare_filter" "geo_filter" {
  expression = "(ip.geoip.country eq \"CN\") or (ip.geoip.country eq \"KP\") or (ip.geoip.country eq \"RU\") or (ip.geoip.country eq \"IR\") or (ip.geoip.country eq \"IQ\") or (ip.geoip.country eq \"SY\")"
  zone_id    = lookup(data.cloudflare_zones.sensei_rat.zones[0], "id")
}

# https://www.terraform.io/docs/providers/cloudflare/r/firewall_rule.html
resource "cloudflare_firewall_rule" "geo_rule" {
  action      = "block"
  filter_id   = cloudflare_filter.geo_filter.id
  zone_id     = lookup(data.cloudflare_zones.sensei_rat.zones[0], "id")
  description = "Block traffic from specific geographic regions."
}

# Cloudflare Zone Settings
# https://www.terraform.io/docs/providers/cloudflare/r/zone_settings_override.html
resource "cloudflare_zone_settings_override" "sensei_zone_settings" {
  zone_id = lookup(data.cloudflare_zones.sensei_rat.zones[0], "id")

  settings {
    always_online    = "on"
    always_use_https = "on"
    http3            = "on"
    tls_1_3          = "on"
    min_tls_version  = "1.2"
    ssl              = "flexible"
    development_mode = "off"
  }
}