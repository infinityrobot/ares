# ARES
class Ares < Thor
  
  # VARIABLES
  RED = "\e[31m"
  YELLOW = "\e[33m"
  GREEN = "\e[32m"
  CYAN = "\e[36m"
  MAGENTA = "\e[35m"
  
  default_files = ["public/index.html", "public/images/rails.png"]
  
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
    invoke :github
    
  end
  
  # default_files - Remove Default Rails files
  desc "default_files", "Removes the default Rails files and clears the README"
  def default_files
    if yes?("Remove the default Rails files and README? (yes/no) ", CYAN)
      default_files.each do |file|
        File.delete(file)
        say("Deleted the file #{file}.")
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
      # Remove Prototype files
      gemfile = File.open("Gemfile", "a")
      gemfile.syswrite("gem \"jquery-rails\"")
      say("Adding jquery-rails gem to Gemfile and running bundle update...")
      system("bundle install --quiet")
      if yes?("Would you like to install jQuery UI as well? (yes/no) ", CYAN)
        system("rails generate jquery:install --ui")
        say("Installed jQuery / jQuery UI as default javascript framework.", GREEN)
      else
        system("rails generate jquery:install")
        say("Installed jQuery as default javascript framework.", GREEN)
      end
      # Commit changes
      system("git add .")
      system("git commit -a -m \"Installed jQuery as default javascript framework.\" -q")    
    end
  end
  
  # github - Set up remote repository and push
  def github
    if yes?("Does the app have a GitHub repository? (yes/no) ")
      github_username = ask("What is your GitHub username? ", CYAN)
      github_repository = ask("What is the repository name? ", CYAN)
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