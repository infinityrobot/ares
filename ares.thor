# ARES
class Ares < Thor
  
  # ADD GEM TO DEVELOPMENT GROUP
  # gemfile = File.read("Gemfile")
  # gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\n  gem \"gemname\"")
  # File.delete("Gemfile")
  # File.open("Gemfile", "+w").syswrite(gemfile)
  
  
  # VARIABLES
  DEFAULT_FILES = ["public/index.html", "public/images/rails.png"]
  
  # --------------------------------------------------------------------------------------------------- #
  # new - Create a new app                                                                              #
  # --------------------------------------------------------------------------------------------------- #
  desc "new", "Create a new Rails app."
  def new
    
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Create a new Rails app with Ares!                                                                        |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    # => Name the app...
    app_name = ask("What would you like your app to be named? ", :cyan).downcase
    app_name = app_name.gsub!(/[^a-z0-9\-_]+/, "_") if app_name.include? " "
    
    # => Create the app and change directory
    say "  => Creating the Rails app #{app_name}."
    system "rails new #{app_name} -q"
    Dir.chdir(app_name)
    app_directory = Dir.pwd
    
    # => Initialize the Git repository
    say "  => Initializing a Git repository for #{app_name}."
    system "git init -q"
    
    # => Add .gitignore
    say "  => Adding .gitignore file."
    gitignore = File.new(".gitignore", "r+")
    gitignore.syswrite(".bundle\ndb/*.sqlite3\nlog/*.log\nlog/*.pid\ntmp/**/*\ntest\npublic/uploads\n")
    
    # => Initial commit
    system "git add ."
    system "git commit -a -m \"Initial commit.\" -q"
    say "  Git Commit: Initial commit.", :blue
    say "Rails app created and Git repository initialized in #{app_directory}", :green
    
    # => Invoke other tasks!
    invoke :default_files
    invoke :jquery
    invoke :haml
    invoke :home
    invoke :forms
    invoke :testing
    invoke :devise
    invoke :omniauth
    invoke :pivotal
    invoke :github
    invoke :capsitrano
    
    # => EDIT README TO SHOW ALL OPTIONS INSTALLED
    
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # default_files - Remove Default Rails files                                                          #
  # --------------------------------------------------------------------------------------------------- #
  desc "default_files", "Removes the default Rails files and clears the README"
  def default_files
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Remove default Rails files                                                                               |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Remove the default Rails files? (y/n) ", :cyan
      DEFAULT_FILES.each do |file|
        File.delete(file)
        say "  => Deleted the file #{file}"
      end
      system "git add ."
      system "git commit -a -m \"Removed default Rails files.\" -q"
      say "  Git Commit: Removed default Rails files.", :blue
      say "Successfully removed the default Rails files!", :green
    end
    if yes? "\nClear the current README? (y/n) ", :cyan
      say "  => Clearing the README..."
      File.open("README", "w").syswrite("")
      system "git add ."
      system "git commit -a -m \"Cleared the README.\" -q"
      say "  Git Commit: Cleared the README.", :blue
      say "Successfully cleared the README!", :green
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # jquery - Set jQuery as the default javascript framework                                             #
  # --------------------------------------------------------------------------------------------------- #
  desc "jquery", "Set jQuery as the default javascript framework instead of Prototype."
  def jquery
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Set jQuery as the default javascript framework instead of Prototype.                                     |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Would you like to use jQuery instead of Prototype? (y/n) ", :cyan
      jquery_ui = yes?("  Would you like to install jQuery UI as well? (y/n) ", :yellow) ? true : false
      
      # => Remove Prototype files
      say "  => Adding jquery-rails gem to Gemfile."
      gemfile = File.read("Gemfile")
      gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\ngem \"jquery-rails\"")
      File.delete("Gemfile")
      File.open("Gemfile", "w+").syswrite(gemfile)
      say "  => Updating bundle..."
      system "bundle install --quiet"
      system "rails generate jquery:install #{"--ui" if jquery_ui == true}"
      
      # => Commit changes
      system "git add ."
      system "git commit -a -m \"Installed jQuery as default javascript framework.\" -q"
      say "  Git Commit: Installed jQuery as default javascript framework.", :blue
      say "Successfully installed jQuery#{" & jQuery UI" if jquery_ui == true} as default javascript framework!", :green
      
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # haml - Set haml as default templating engine                                                        #
  # --------------------------------------------------------------------------------------------------- #
  desc "haml", "Set Haml (with SCSS) as the default templating engine."
  def haml
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Set Haml (with SCSS) as the default templating engine.                                                   |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Would you like to use Haml for cleaner markup? (y/n) ", :cyan
      
      # => Add to Gemfile and update bundle
      say "  => Adding Haml gem to Gemfile"
      gemfile = File.read("Gemfile")
      gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\ngem \"haml\"")
      File.delete("Gemfile")
      File.open("Gemfile", "w+").syswrite(gemfile)
      say "  => Updating bundle..."
      system "bundle install --quiet"
      
      if yes? "  Would you like to install Haml as the default templating engine? (y/n) ", :yellow
        say "  => Updating config/application.rb..."
        app_config = File.read("config/application.rb")
        app_config = app_config.gsub("  end\nend", "\n    # GENERATORS\n    config.generators do |g|\n      g.template_engine :haml\n    end\n  end\nend")
        File.delete("config/application.rb")
        File.open("config/application.rb", "w+").syswrite(app_config)
      end
      
      # => Commit changes
      system "git add ."
      system "git commit -a -m \"Added Haml templating engine.\" -q"
      say "  Git Commit: Added Haml templating engine.", :blue
      say "Successfully installed Haml! Enjoy cleaner markup!", :green
      
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # home - Set up Home controller                                                                       #
  # --------------------------------------------------------------------------------------------------- #
  desc "home", "Add a root controller for a home / welcome page."
  def home
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Add a root controller for a home / welcome page.                                                         |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Would you like to create a root controller for a home page for your app? (y/n) ", :cyan
      
      # => Name the root controller
      root_controller_name = ask("  What would you like to name your Home Page controller?", :yellow).downcase
      root_controller_name = root_controller_name.gsub!(/[^a-z0-9\-_]+/, "_") if root_controller_name.include? " "
      
      # => Generate the controller
      say "  => Creating the controller \"#{root_controller_name}\"..."
      system "rails generate controller #{root_controller_name} index"
      
      # => Add root route to routes.rb
      say "  => Adding root route to routes.rb..."
      routes = File.read("config/routes.rb")
      routes = routes.gsub("routes.draw do", "routes.draw do\n\n  root :to => 'home#index'")
      File.delete("config/routes.rb")
      File.open("config/routes.rb", "w+").syswrite(routes)
      
      # => Commit changes
      system "git add ."
      system "git commit -a -m \"Added Home controller for home page.\" -q"
      say "  Git Commit: Added Home controller for home page.", :blue
      say "Successfully added Home controller for a home / welcome page.", :green
      
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # testing - Set up Testing Framworks                                                                  #
  # --------------------------------------------------------------------------------------------------- #
  desc "testing", "Set up testing frameworks for your app."
  def testing
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Set up testing frameworks for your app.                                                                  |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    cucumber = yes?("Would you like to use Cucumber for integration testing? (y/n) ", :cyan) ? true : false
    # => Check for Cucumber options / add-ins
    if cucumber
      capybara = yes?("  Would you like to use Capybara for interactions with Cucumber? (y/n) ", :yellow) ? true : false
      email_spec = yes?("  Would you like to test the sending / receipt of emails in your Cucumber tests? [Adds email_spec gem and steps] (y/n) ", :yellow) ? true : false
      fakeweb = yes?("  Would you like to block HTTP requests in your tests? [Adds fakeweb gem] (y/n) ", :yellow) ? true : false
    end
    rspec = yes?("Would you like to use RSpec for unit testing? (y/n) ", :cyan) ? true : false
    seed = yes?("Would you like to seed test data in your tests? [Adds machinist and faker gems] (y/n) ", :cyan) ? true : false
    
    # => Add required gems to Gemfile
    if cucumber || rspec || seed || fakeweb
      say "  => Adding required testing / development gems to Gemfile..."
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite(
%Q{
# TESTING / DEVELOPMENT GEMS
group :development, :test do
#{"  gem 'cucumber'
  gem 'cucumber-rails'            # => Rails generators for Cucumber - http://github.com/aslakhellesoy/cucumber-rails" if cucumber}
#{"  gem 'capybara'                  # => Rails testing driver - http://github.com/jnicklas/capybara" if capybara}
#{"  gem 'rspec'                     # => Behaviour driven development for ruby - http://github.com/rspec/rspec
  gem 'rspec-rails'               # => RSpec extension library for Ruby on Rails - http://github.com/rspec/rspec-rails" if rspec}
#{"  gem 'database_cleaner'          # => For cleaning database between test sessions - http://github.com/bmabey/database_cleaner
  gem 'spork'                     # => DRb server for testing frameworks - http://github.com/timcharper/spork
  gem 'launchy'                   # => Helper class for launching applications - http://copiousfreetime.rubyforge.org/launchy/" if cucumber || rspec}
#{"  gem 'machinist'                 # => For creating seed data / database population - http://github.com/notahat/machinist
  gem 'faker'                     # => For generating random data - http://faker.rubyforge.org/" if seed}
#{"  gem 'fakeweb'                   # => For blocking external HTTP access in tests - http://github.com/chrisk/fakeweb" if fakeweb}
#{"  gem 'email_spec'                # => For testing ActionMailer in Cucumber - http://github.com/bmabey/email-spec" if email_spec}
end
})
      # => Bundle update to install gems and commit changes
      say "  => Running bundle install..."
      system "bundle install --quiet"
      system "git add ."
      system "git commit -a -m \"Added testing gems to Gemfile.\" -q"
      say "  Git Commit: Added testing gems to Gemfile.", :blue
    end
    
    # => Install RSpec
    if rspec
      say "  => Installing RSpec..."
      system "rails generate rspec:install --quiet"
      say "  => RSpec installed!", :green
      system "git add ."
      system "git commit -a -m \"Added RSpec for unit testing.\" -q"
      say "  Git Commit: Added RSpec for unit testing.", :blue
      
    end
    
    # => Run Cucumber generator
    if cucumber
      say "  => Installing Cucumber..."
      system "rails generate cucumber:install#{" --capybara" if capybara == true}#{" --rspec" if rspec == true} --quiet"
      say "  => Cucumber installed!", :green
      system "git add ."
      system "git commit -a -m \"Added Cucumber for integration testing.\" -q"
      say "  Git Commit: Added Cucumber for integration testing.", :blue
      
    end
    
    # => Run email_spec generator commands
    if email_spec
      say "  => Installing Cucumber email steps..."
      system "rails generate email_spec:steps --quiet"
      say "  => Cucumber email steps installed to features/step_definitions/email_steps.rb!", :green
      system "git add ."
      system "git commit -a -m \"Added email_spec test steps for testing emails with Cucumber.\" -q"
      say "  Git Commit: Added email_spec test steps for testing emails with Cucumber.", :blue
    end
    
    # => Installing Fakeweb
    if fakeweb
      say "  => Installing Fakeweb..."
      fakeweb_file = File.new("features/support/fakeweb.rb", "w+")
      fakeweb_file.syswrite("# Fakeweb URI definitions\nFakeWeb.allow_net_connect = false # Doesn't allow testing to connect to the internet")
      say "  => Fakeweb installed with config in features/support/fakeweb.rb!", :green
      system "git add ."
      system "git commit -a -m \"Added Fakeweb for blocking HTTP requests in tests.\" -q"
      say "  Git Commit: Added Fakeweb for blocking HTTP requests in tests.", :blue
    end
    
    # => Success notice
    say "Test suite successfully installed!", :green
    
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # devise - Set up Devise authentication                                                               #
  # --------------------------------------------------------------------------------------------------- #
  desc "devise", "Add User authentication with Devise."
  def devise
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Add User authentication with Devise.                                                                     |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Would you like to include Devise authentication as an authentication solution for your app? (y/n) ", :cyan
    
      # => Add Devise gem to Gemfile
      say "  => Adding Devise gem to Gemfile..."
      gemfile = File.read("Gemfile")
      gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\n  gem 'devise', :git => 'git://github.com/plataformatec/devise.git'  # => For user authentication - http://github.com/plataformatec/devise")
      File.delete("Gemfile")
      File.open("Gemfile", "w+").syswrite(gemfile)
      say "  => Updating bundle..."
      system "bundle install --quiet"
      system "git add ."
      system "git commit -a -m \"Added Devise to Gemfile.\" -q"
      say "  Git Commit: Added Devise to Gemfile.", :blue
      
      # => Install Devise
      say "  => Installing Devise..."
      system "rails generate devise:install -q"
      say "  => Devise is installed!", :green
      system "git add ."
      system "git commit -a -m \"Installed Devise for authentication.\" -q"
      say "  Git Commit: Installed Devise for authentication.", :blue
      
      # => Add Devise model
      devise_model = ask("  What would you like to name your Devise model? (User, Admin, etc) ", :yellow).downcase
      devise_model = devise_model.gsub!(/[^a-z0-9\-_]+/, "_") if devise_model.include? " "
      say "  => Generating the Devise model..."
      system "rails generate devise #{devise_model} -q"
      say "  => Devise model for #{devise_model} generated!", :green
      system "git add ."
      system "git commit -a -m \"Added #{devise_model} model for Devise authentication.\" -q"
      say "  Git Commit: Added #{devise_model} model for Devise authentication.", :blue
      
      # => Add custom Devise routes
      if yes? "  Would you like to add some custom routes for your Devise model? (y/n)", :yellow
        # Define routes to use
        devise_sign_in_route = ask "    What would you like your Devise Sign In route to be? (ie, login)"
        devise_sign_out_route = ask "    What would you like your Devise Sign Out route to be? (ie, logout)"
        devise_sign_up_route = ask "    What would you like your Devise Sign Up route to be? (ie, signup)"
        devise_edit_route = ask "    What would you like your Devise Edit Registrations route to be? (ie, settings)"
        # Add routes to routes.rb
        say "    => Adding custom Devise routes to routes.rb..."
        routes_text = File.read("config/routes.rb")
        routes_text = routes_text.gsub("devise_for :#{devise_model}s",
  %Q{devise_for :users, :path_names => { :sign_in => '#{devise_sign_in_route}', :sign_out => '#{devise_sign_out_route}', :sign_up => '#{devise_sign_up_route}' } do # Customise Devise /users/:actions
      get '#{devise_sign_up_route}', :to => 'registrations#new'
      get '#{devise_sign_in_route}', :to => 'devise/sessions#new'
      get '#{devise_sign_out_route}', :to => 'devise/sessions#destroy'
      get '#{devise_edit_route}', :to => 'registrations#edit'
    end
  })
        File.delete("config/routes.rb")
        File.open("config/routes.rb", "w+").syswrite(routes_text)
        # Commit changes
        system "git add ."
        system "git commit -a -m \"Added custom Devise routes.\" -q"
        say "  Git Commit: Added #{devise_model} model for Devise authentication.", :blue
      end
    
      # => Copy Devise views
      if yes? "  Would you like to add Devise views to your app? (y/n)", :yellow
        template_engine = ask "    Which template engine would you like to use to generate your Devise views? (haml/erb/slim)"  # !!! CHANGE TO GLOBAL OPTION LATER
        # !!! CHECK IF HAML IS INSTALLED
        if template_engine == "haml" || template_engine == "slim"
          say "    => Installing gems required to generate views..."
          gemfile = File.open("Gemfile", "a")
          gemfile.syswrite(
  %Q{
  gem 'hpricot'                   # => For generating HAML Devise views - http://github.com/hpricot/hpricot
  gem 'ruby_parser'               # => For generating HAML Devise views
  })
          system "bundle install --quiet"
          say "    => Gems all installed!", :green
        end
        say "    => Generating Devise views in #{template_engine}..."
        system "rails generate devise:views --template-engine=#{template_engine.downcase} -q"
        say "    => Devise views have been generated!", :green
        system "git add ."
        system "git commit -a -m \"Generated Devise views in #{template_engine}.\" -q"
        say "  Git Commit: Generated Devise views in #{template_engine}.", :blue
      end
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # omniauth - Set up Omniauth social authentication                                                    #
  # --------------------------------------------------------------------------------------------------- #
  desc "omniauth", "Add external authentication for Devise through Omniauth."
  def omniauth
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Add external authentication for Devise through Omniauth.                                                 |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Would you like use Omniauth with Devise for external authentication? This will only work for a model named 'User'! (y/n) ", :red
      
      # => Add Omniauth gem to Gemfile
      say "  => Adding OmniAuth to Gemfile..."
      gemfile = File.read("Gemfile")
      gemfile = gemfile.gsub("source 'http://rubygems.org'", "source 'http://rubygems.org'\n\n  gem 'omniauth', :git => 'git://github.com/intridea/omniauth.git' # => Allows the use of external authentications - http://github.com/intridea/omniauth")
      File.delete("Gemfile")
      File.open("Gemfile", "w+").syswrite(gemfile)
      say "  => Updating bundle..."
      system "bundle install --quiet"
      system "git add ."
      system "git commit -a -m \"Added OmniAuth to Gemfile.\" -q"
      say "  Git Commit: Added OmniAuth to Gemfile.", :blue
      
      # => Set external auth parameters
      if facebook = yes?("  Would you like to use Facebook as an external authentication provider? (y/n) ", :yellow)
        facebook_app_id = ask "    What is your Facebook App ID?"
        facebook_app_secret = ask "    What is your Facebook App secret?"
        facebook_scope = ask "    What scope will your app require? (email, publish_stream, offline_access)"
      end
      if twitter = yes?("  Would you like to use Twitter as an external authentication provider? (y/n) ", :yellow)
        twitter_app_id = ask "    What is your Twitter App ID?"
        twitter_app_secret = ask "    What is your Twitter App secret?"
      end
      if linked_in = yes?("  Would you like to use LinkedIn as an external authentication provider? (y/n) ", :yellow)
        linked_in_app_id = ask "    What is your LinkedIn App ID?"
        linked_in_app_secret = ask "    What is your LinkedIn App secret?"
      end
      
      # => Write options to Devise initializer
      say "  => Adding Omniauth options to Devise initializer..."
      devise_config = File.read("config/initializers/devise.rb")
      devise_config = devise_config.gsub("# ==> OmniAuth",
%Q{# ==> OmniAuth
#{"  config.omniauth :facebook, \"#{facebook_app_id}\", \"#{facebook_app_secret}\", :scope => \"#{facebook_scope}\"" if facebook}
#{"  config.omniauth :twitter, \"#{twitter_app_id}\", \"#{twitter_app_secret}\""if twitter}
#{"  config.omniauth :linked_in, \"#{linked_in_app_id}\", \"#{linked_in_app_secret}\"" if linked_in}})
      File.delete("config/initializers/devise.rb")
      File.open("config/initializers/devise.rb", "w+").syswrite(devise_config)
      system "git add ."
      system "git commit -a -m \"Added OmniAuth config to Devise initializer.\" -q"
      say "  Git Commit: Added OmniAuth config to Devise initializer.", :blue
      
      # => Make Devise model Omniauthable
      say "  => Applying OmniAuthable to the User model..."
      devise_omniauthable = File.read("app/models/user.rb")
      devise_omniauthable = devise_omniauthable.gsub(":validatable", ":validatable, :omniauthable")
      File.delete("app/models/user.rb")
      File.open("app/models/user.rb", "w+").syswrite(devise_omniauthable)
      system "git add ."
      system "git commit -a -m \"Made User omniauthable for OmniAuth through Devise.\" -q"
      say "  Git Commit: Made User omniauthable for OmniAuth through Devise.", :blue
      
      # => Create Authentication model
      say " => Creating Authentication model to store external authentications..."
      system "rails generate model Authentication user_id:integer provider:string uid:string token:string"
      File.delete("app/models/authentication.rb")
      File.open("app/models/authentication.rb", "w+").syswrite(
%Q{class Authentication < ActiveRecord::Base

  # ASSOCIATIONS
  belongs_to :user

  # SCOPES
  scope :facebook, where(:provider => "facebook")
  scope :twitter, where(:provider => "twitter")
  scope :linkedin, where(:provider => "linked_in")

end})
      system "git add ."
      system "git commit -a -m \"Added Authentication model for OmniAuth authentications.\" -q"
      say "  Git Commit: Added Authentication model for OmniAuth authentications.", :blue
      
      # => Create Authentications controller
      say "  => Creating Authentications controller..."
      system "rails generate controller Authentications"
      File.delete("app/controllers/authentications_controller.rb")
      File.open("app/controllers/authentications_controller.rb", "w+").syswrite(
%q{class AuthenticationsController < Devise::OmniauthCallbacksController

  # CAPTURES ALL POSSIBLE OMNIAUTH PROVIDOR METHODS - As Omniauth requires a providor method - method missing captures it.
  def method_missing(provider)
    omniauth = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
    if authentication
      flash[:notice] = "Welcome back! You're all signed in."
      sign_in_and_redirect(:user, authentication.user)
    elsif signed_in_resource
      signed_in_resource.authentications.create!(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => (omniauth['credentials']['token'] rescue nil))
      redirect_to root_path, :notice => "Successfully added #{omniauth['provider'].camelcase} to your profile!"
    else
      user = User.new
      user.apply_omniauth(omniauth)
      if user.save
        flash[:notice] = "Welcome! You just connected via #{omniauth['provider'].camelcase}."
        sign_in_and_redirect(:user, user)
      else
        if omniauth['provider'] == "twitter"
          session["devise.omniauth"] = omniauth.except('extra')
        else
          session["devise.omniauth"] = omniauth
        end
        redirect_to new_user_registration_path
      end
    end
  end

  # DESTROY OMNIAUTH SESSION
  def destroy_session
    session.delete("devise.omniauth")
    redirect_to new_user_registration_path
  end

end})
      system "git add ."
      system "git commit -a -m \"Added Authentication controller for handling OmniAuth authentications.\" -q"
      say "  Git Commit: Added Authentication controller for handling OmniAuth authentications.", :blue
      
      # => Create Registrations controller to handle registrations through OmniAuth
      say "  => Creating Registrations controller..."
      File.open("app/controllers/registrations_controller.rb", "w+").syswrite(
%q{class RegistrationsController < Devise::RegistrationsController

  private

  def build_resource(*args)
    super
    if omniauth          = session['devise.omniauth']
      # APPLY OMNIAUTH AUTRIBUTES
      @user.apply_omniauth(omniauth)
      # FACEBOOK ATTRIBUTES
      if omniauth['provider'] == "facebook"
        #@user.first_name = omniauth['user_info']['first_name']
        #@user.last_name  = omniauth['user_info']['last_name']
      # TWITTER ATTRIBUTES
      elsif omniauth['provider'] == "twitter"
        #full_name        = omniauth['user_info']['name']
        #@user.first_name = full_name.split.first
        #@user.last_name  = full_name.split.last
        #@user.bio        = omniauth['user_info']['description']
      end
    end
  end

  # REDIRECT ON PROFILE EDIT - https://github.com/plataformatec/devise/wiki/How-To:-Customize-the-redirect-after-a-user-edits-their-profile
  def after_update_path_for(resource)
    user_path(resource)
  end

end})
      system "git add ."
      system "git commit -a -m \"Added Registrations controller for handling new registrations through OmniAuth authentications.\" -q"
      say "  Git Commit: Added Registrations controller for handling new registrations through OmniAuth authentications.", :blue
      
      # => Add methods to the User model
      say "  => Adding Omniauth methods to User model..."
      user_model = File.read("app/models/user.rb")
      user_model = user_model.gsub("class User < ActiveRecord::Base",
%Q{class User < ActiveRecord::Base
  
  # CALLBACKS
  before_destroy :destroy_authentications # Destroys any associated authentications})
      user_model = user_model.gsub("end", 
%Q{  # OMNIAUTH METHODS
  def password_required? # Password isn't required if authenticating externally
    (authentications.empty? || !password.blank?) && super
  end

  def update_with_password(params={}) # Users don't have to enter their current password to update their profile
    if params[:password].blank? 
      params.delete(:password) 
      params.delete(:password_confirmation) if params[:password_confirmation].blank? 
    end 
    update_attributes(params) 
  end

  def apply_omniauth(omniauth) # Build the authentication of the user
    authentications.build(:provider => omniauth['provider'], :uid => omniauth['uid'], :token => (omniauth['credentials']['token'] rescue nil))
  end

  def has_auth(auth_provider)
    authentications.find_by_provider(auth_provider)
  end

  # PRIVATE METHODS
  private
  
    def destroy_authentications # Destroys the authentications of a user on delete
      @authentications = Authentication.find_all_by_user_id(self.id)
      @authentications.each do |authentication|
        authentication.destroy
      end
    end

end})
      
      File.delete("app/models/user.rb")
      File.open("app/models/user.rb", "w+").syswrite(user_model)
      system "git add ."
      system "git commit -a -m \"Added OmniAuth methods to User model.\" -q"
      say "  Git Commit: Added OmniAuth methods to User model.", :blue
      
      # => Add new controllers to Devise routes
      say "  => Adding new controllers to Devise routes..."
      omniauth_routes = File.read("config/routes.rb")
      omniauth_routes = omniauth_routes.gsub("devise_for :users", "devise_for :users, :controllers => { :registrations => \"registrations\", :omniauth_callbacks => \"authentications\"")
      File.delete("config/routes.rb")
      File.open("config/routes.rb", "w+").syswrite(omniauth_routes)
      system "git add ."
      system "git commit -a -m \"Added OmniAuth controllers to Devise routes.\" -q"
      say "  Git Commit: Added OmniAuth controllers to Devise routes.", :blue
      
      
      # => Finished! *phew*
      say "OmniAuth authentication has been added to the User model!", :green
      
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # pivotal - Set up Pivotal Tracker project                                                            #
  # --------------------------------------------------------------------------------------------------- #
  desc "pivotal", "Add Pivotal Tracker support through the Pickler gem."
  def pivotal
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Add Pivotal Tracker support through Pickler.                                                             |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Would you like to setup Pivotal Tracker support through the Pickler gem? (y/n) ", :cyan
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite(
%Q{
group :development do
  gem 'pickler'
end})
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # capistrano - Set up deploy.rb for Capistrano deployment                                             #
  # --------------------------------------------------------------------------------------------------- #
  desc "capistrano", "Add Capistrano support for easy deployment."
  def capistrano
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Add Capistrano support for easy deployment.                                                              |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    # => !!! Capistrano code here
    # => !!! Nginx support
    # => !!! Whenever cron tab stuff
    # => !!! Delayed_job stuff
    # => !!! 
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # forms - Use formtastic for semantic webforms                                                        #
  # --------------------------------------------------------------------------------------------------- #
  desc "forms", "Add Formtastic support for semantic web forms."
  def forms
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Adds Formtastic support for semantic web forms.                                                          |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Would you like to use Formtastic for semantic web forms? (y/n) ", :cyan
      # => Add Formtastic to Gemfile
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite("gem 'formtastic'                  # => For sexy forms - http://github.com/justinfrench/formtastic")
      # => Commit changes
      system "git add ."
      system "git commit -a -m \"Added Formtastic for semantic web forms.\" -q"
    end
  end
  
  # --------------------------------------------------------------------------------------------------- #
  # github - Set up remote repository and push                                                          #
  # --------------------------------------------------------------------------------------------------- #
  desc "github", "Add remote GitHub repository to app and push."
  def github
    
    say "\n"
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    say "| Add remote GitHub repository to app and push.                                                            |", :magenta
    say "|----------------------------------------------------------------------------------------------------------|", :magenta
    
    if yes? "Does the app have a GitHub repository? (y/n) ", :cyan
      github_username = ask "What is your GitHub username? ", :yellow
      github_repository = ask "What is the repository name? ", :yellow
      github_path = "git@github.com:#{github_username}/#{github_repository}.git"
      # Add remote repository
      system "git remote add origin #{github_path}"
      say "Added remote origin at #{github_path}"
      # Push to remote repository
      if yes? "Would you like to push to #{github_path}? (y/n) ", :cyan
        say "Pushing to master at #{github_path}..."
        system "git push origin master"
        say "Your app has been pushed!", :green
      end
    end
  end
  
end