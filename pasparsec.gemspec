Gem::Specification.new do |s|
  s.name = "pasparsec"
  s.version = File.read("VERSION")
  s.authors = ["pasberth"]
  s.description = %{A parsing library like the Parsec}
  s.summary = %q{}
  s.email = "pasberth@gmail.com"
  s.extra_rdoc_files = ["README.rdoc"]
  s.rdoc_options = ["--charset=UTF-8"]
  s.homepage = "http://github.com/pasberth/PasParsec"
  s.require_paths = ["lib"]
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- spec/*`.split("\n")
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec"
end
