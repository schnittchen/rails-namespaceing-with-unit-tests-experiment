task :spec do
  files = %w{
    1st_user_spec.rb
    2nd_user_invitation_spec.rb
    3rd_user_spec.rb
    4th_user_invitation_spec.rb
  }.map { |basename| 'spec/models/' + basename }

  (1..files.length).map do |subset_card|
    files.combination(subset_card).to_a
  end.reduce(:+).each do |sets_of_files|
    system('rspec',
      '-f', 'progress',
           *sets_of_files)
  end
end

