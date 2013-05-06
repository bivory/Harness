#!/usr/bin/env ruby

class Command
  Tests = {
    "unclassified" => "unclassified",
    "successful"  => "successful",
    "unsuccessful" =>  "failed"
  }

  def get_files(path)
    files = Dir.glob(path + '/*')
  end
end

class CommandResults < Command
  def description() "Print the test results." end

  def print_file_result(title, path)
    files = get_files(path)
    printf "%s (%d):\n", title, files.length
    files.select{|f| puts f}
  end

  def run()
    print_file_result("Unclassified Tests", Tests["unclassified"])
    print_file_result("Successful Tests", Tests["successful"])
    print_file_result("Unsuccessful Tests", Tests["unsuccessful"])
  end
end

class CommandHelp < Command
  def description() "Print this help message." end
  def run()
    puts "Help me"
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
    command.run()
  end
end

harness = Harness.new()
harness.run ARGV
