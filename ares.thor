# ARES
class Ares < Thor
  
  # VARIABLES
  RED = "\e[31m"
  YELLOW = "\e[33m"
  GREEN = "\e[32m"
  CYAN = "\e[36m"
  MAGENTA = "\e[35m"
  
  DEFAULT_FILES = ["public/index.html", "public/images/rails.png"]
  
  
  # new - Create a new app
  desc "new", "Create a new Rails app."
  def new
    
    # => Name the app...
    say("Creating a new Rails app using Ares...")
    app_name = ask("What would you like your app to be named? ", CYAN).downcase
    app_name = app_name.gsub!(/[^a-z0-9\-_]+/, "_") if app_name.include? " "
    
    # => Create the app and change directory
    say("Creating the Rails app #{app_name}.")
    system("rails new #{app_name} -q")
    Dir.chdir(app_name)
    app_directory = Dir.pwd
    
    # => Initialize the Git repository
    say("Initializing a Git repository for #{app_name}.")
    system("git init -q")
    
    # => Add .gitignore
    say("Adding .gitignore file.")
    gitignore = File.new(".gitignore", "r+")
    gitignore.syswrite(".bundle\ndb/*.sqlite3\nlog/*.log\nlog/*.pid\ntmp/**/*\ntest\npublic/uploads\n")
    
    # => Initial commit
    system("git add .")
    system("git commit -a -m \"Initial commit.\" -q")
    say("Rails app created and Git repository initialized in #{app_directory}", GREEN)
    
    # => Invoke other tasks!
    invoke :default_files
    invoke :jquery
    invoke :testing
    invoke :pivotal
    invoke :github
    
  end
  
  # default_files - Remove Default Rails files
  desc "default_files", "Removes the default Rails files and clears the README"
  def default_files
    if yes?("Remove the default Rails files and README? (yes/no) ", CYAN)
      DEFAULT_FILES.each do |file|
        File.delete(file)
        say("Deleted the file #{file}")
      end
      File.open("README", "w").write("")
      say("Reset README to be blank.")
      # Commit changes
      system("git add .")
      system("git commit -a -m \"Removed default Rails files and README.\" -q")
      say("Default Rails files and README have been deleted!", GREEN)
    end
  end
  
  # jquery - Set jQuery as the default javascript framework
  desc "jquery", "Set jQuery as the default javascript framework instead of Prototype."
  def jquery
    if yes?("Would you like to use jQuery instead of Prototype? (yes/no) ", CYAN)
      jquery_ui = yes?("Would you like to install jQuery UI as well? (yes/no) ", YELLOW) ? true : false
      # Remove Prototype files
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite("gem \"jquery-rails\"")
      say("Adding jquery-rails gem to Gemfile and running bundle update...")
      system("bundle install --quiet")
      system("rails generate jquery:install #{"--ui" if jquery_ui == true}")
      say("Installed jQuery#{" & jQuery UI" if jquery_ui == true} as default javascript framework.", GREEN)
      # Commit changes
      system("git add .")
      system("git commit -a -m \"Installed jQuery as default javascript framework.\" -q")    
    end
  end
  
  # testing - Set up Testing Framworks
  desc "testing", "Sets up testing frameworks for your app."
  def testing
    
    cucumber = yes?("Would you like to use Cucumber for integration testing? (yes/no) ", CYAN) ? true : false
    rspec = yes?("Would you like to use RSpec for unit testing? (yes/no) ", CYAN) ? true : false
    seed = yes?("Would you like to seed test data in your tests? [Adds machinist and faker gems] (yes/no) ", CYAN) ? true : false
    fakeweb = yes?("Would you like to block HTTP requests in your tests? [Adds fakeweb gem] (yes/no) ", CYAN) ? true : false
    
    if cucumber == true
      capybara = yes?("Would you like to use Capybara for interactions with Cucumber? (yes/no) ", CYAN) ? true : false
      emails = yes?("Would you like to test the sending / reciept of emails? [Adds email_spec gem] (yes/no) ", CYAN) ? true : false
      # => Add cucumber and other required gems to Gemfile
      say("Adding testing / development gems to Gemfile..")
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite(
%Q{
# TESTING / DEVELOPMENT GEMS
group :development, :test do
  gem 'cucumber'
  gem 'cucumber-rails'            # => Rails generators for Cucumber - http://github.com/aslakhellesoy/cucumber-rails
#{"  gem 'capybara'                  # => Rails testing driver - http://github.com/jnicklas/capybara" if capybara == true}
#{"  gem 'rspec'                     # => Behaviour driven development for ruby - http://github.com/rspec/rspec
  gem 'rspec-rails'               # => RSpec extension library for Ruby on Rails - http://github.com/rspec/rspec-rails" if rspec == true}
  gem 'database_cleaner'          # => For cleaning database between test sessions - http://github.com/bmabey/database_cleaner
  gem 'spork'                     # => DRb server for testing frameworks - http://github.com/timcharper/spork
  gem 'launchy'                   # => Helper class for launching applications - http://copiousfreetime.rubyforge.org/launchy/
#{"  gem 'machinist'                 # => For creating seed data / database population - http://github.com/notahat/machinist
  gem 'faker'                     # => For generating random data - http://faker.rubyforge.org/" if seed == true}
#{"  gem 'fakeweb'                   # => For blocking external HTTP access in tests - http://github.com/chrisk/fakeweb" if fakeweb == true}
#{"  gem 'email_spec'                # => For testing ActionMailer in Cucumber - http://github.com/bmabey/email-spec" if emails == true}
end
})
      # => Bundle update to install gems and commit changes
      say("Running bundle install...")
      system("bundle install --quiet")
      system("git add .")
      system("git commit -a -m \"Added testing gems to Gemfile.\" -q")
      
      # => Install RSpec
      if rspec == true
        say("Installing RSpec...")
        system("rails generate rspec:install --quiet")
        say("RSpec installed!", GREEN)
        system("git add .")
        system("git commit -a -m \"Added RSpec for unit testing.\" -q")
      end
      
      # => Run Cucumber generator
      if cucumber == true
        say("Installing Cucumber...")
        system("rails generate cucumber:install#{" --capybara" if capybara == true}#{" --rspec" if rspec == true} --quiet")
        say("Cucumber installed!", GREEN)
        system("git add .")
        system("git commit -a -m \"Added Cucumber for integration testing.\" -q")
      end
      
      # => Run email_spec generator commands
      if emails == true
        say("Installing Cucumber email steps...")
        system("rails generate email_spec:steps --quiet")
        say("Cucumber email steps installed to features/step_definitions/email_steps.rb!", GREEN)
        system("git add .")
        system("git commit -a -m \"Added email_spec test steps for testing emails with Cucumber.\" -q")
      end
      
      # => Installing Fakeweb
      if fakeweb == true
        say("Installing Fakeweb...")
        fakeweb_file = File.new("features/support/fakeweb.rb", "w+")
        fakeweb_file.syswrite("# Fakeweb URI definitions\nFakeWeb.allow_net_connect = false # Doesn't allow testing to connect to the internet")
        say("Fakeweb installed with config in features/support/fakeweb.rb!", GREEN)
        system("git add .")
        system("git commit -a -m \"Added Fakeweb for blocking HTTP requests in tests.\" -q")
      end
      
      # => Success notice
      say("Test suite successfully installed!", GREEN)
      
    end
  end
  
  # pivotal - Set up Pivotal Tracker project
  desc "pivotal", "Add Pivotal Tracker support through the Pickler gem."
  def pivotal
    # => Pivotal code
  end
  
  # github - Set up remote repository and push
  desc "github", "Add remote GitHub repository to app and push."
  def github
    if yes?("Does the app have a GitHub repository? (yes/no) ", CYAN)
      github_username = ask("What is your GitHub username? ", YELLOW)
      github_repository = ask("What is the repository name? ", YELLOW)
      github_path = "git@github.com:#{github_username}/#{github_repository}.git"
      # Add remote repository
      system("git remote add origin #{github_path}")
      # Push to remote repository
      if yes?("Would you like to push to #{github_path}? (yes/no) ")
        say("Pushing to master at #{github_path}...")
        system("git push origin master")
        say("Your app has been pushed!", GREEN)
     end
    end
  end
  
end