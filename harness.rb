#!/usr/bin/env ruby

class Command
  Tests = {
    "unclassified" => "unclassified",
    "successful"  => "successful",
    "unsuccessful" =>  "failed"
  }

  def get_files(path) Dir.glob(path + '/*') end
  def get_unclassified() get_files(Tests["unclassified"]) end
  def get_successful() get_files(Tests["successful"]) end
  def get_unsuccessful() get_files(Tests["unsuccessful"]) end
  def get_all() get_unclassified() + get_successful() + get_unsuccessful() end
end

class CommandResults < Command
  def description() "Print the test results." end

  def print_results_for(title, files, verbose)
    printf "%s (%d)\n", title, files.length
    if verbose
      files.select{|f| puts f}
      print "\n"
    end
  end

  def run(args, commands)
    verbose = args[1] == "-v"
    print_results_for("Unclassified Tests", get_unclassified(), verbose)
    print_results_for("Successful Tests", get_successful(), verbose)
    print_results_for("Unsuccessful Tests", get_unsuccessful(), verbose)
    printf "Total (%d)\n", get_all().length
  end
end

class CommandHelp < Command
  def description() "Print this help message." end
  def run(args, commands)
    puts "=== VALID HARNESS COMMANDS ==="
    commands.each{|k,v| puts k + ": " + v.description()}
  end
end

class Harness
  Commands = {
    "results" => CommandResults.new(),
    "help"    => CommandHelp.new()
  }

  def initialize()
  end

  def run(args)
    command = Commands[args[0]]
    command = Commands["help"] if command.nil?
    command.run(args, Commands)
  end
end

harness = Harness.new()
harness.run ARGV
