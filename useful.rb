Dir::glob("./Scripts/**/*.rb").each do |fn|
    str = ""
  File::open(fn, "r+") do |f|
    str = f.read
  end
  File::open(fn, "w+") do |f|
    f.write str.gsub('$root_path +', '')
  end
end