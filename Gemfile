source 'http://rubygems.org'

if ENV["RM_INFO"] && ARGV[0] == 'check'
  puts "Execution in RubyMine detected in Gemfile. Ignoring decko gem path"
  # This causes Rubymine and IntelliJ to handle these paths as normal sources rather
  # than gems or libraries.
  # That way the files are included as normal project sources in Find and Open.
else
  gem "decko", path: "./vendor/decko"

  path "./vendor/decko/mod" do
    gem "card-mod-defaults"
    gem "card-mod-delayed_job"
    gem "card-mod-monkey", group: :development
  end

  gem "card-mod-new_relic", path: "./vendor/card-mods"
end

gem "mysql2", "> 0.4"

gem "yard"
gem "puma" # needed for yard and development

# gem "mail", "2.7.1" # 2.8.0 breaking?

group :production do
  gem "dalli"
  gem "fog-aws"
end

# gem "fog-aws"
gem 'net-smtp', require: false

# VERSIONING ISSUES
#gem "ffi", "1.16.3"                  # 1.17 requires rubygems version >= 3.3.22


# gem 'net-pop', require: false
# gem 'net-imap', require: false

# The following allows simple (non-gem) mods to specify gems via a Gemfile.
# You may need to alter this code if you move such mods to an unconventional location.
# Dir.glob("mod/**/Gemfile").each { |gemfile| instance_eval File.read(gemfile) }
