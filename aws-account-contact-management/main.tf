resource "aws_account_primary_contact" "main" {
  country_code    = "JP"
  postal_code     = "101-0025"
  state_or_region = "Tokyo-to"
  city            = "Minato-ku"
  address_line_1  = "1-1 Nishishinbashi"
  full_name       = "Test Taro"
  phone_number = "+81xxxxxxx"
  company_name = "Classmethod,Inc"
  website_url  = "https://classmethod.jp/"
}

resource "aws_account_alternate_contact" "operations" {

  alternate_contact_type = "OPERATIONS"

  name          = "Test Taro"
  title         = "general"
  email_address = "test@example.com"
  phone_number  = "+81xxxxxxx"
}
