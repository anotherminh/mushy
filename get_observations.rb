require 'rest_client'
require 'json'

TOKEN = ENV['INAT-TOKEN']
HEADERS = {'Accept' => 'application/json', "Authorization" => "Bearer #{TOKEN}"}

module MushroomData
  TAXA = {
    # Agaricus
    'Agaricus-arvensis' => 58699,
    'Agaricus-campestris' => 143563,
    'Agaricus-californicus' => 118379,
    'Agaricus-xanthodermus' => 118394,
    'Pluteus-cervinus' => 60782,
    'Pluteus-exilis' => 351891,
    # Amanita
    'Amanita-bisporigera' => 125390,
    'Amanita-caesarea' => 204588,
    'Amanita-calyptroderma' => 53884,
    'Amanita-brunnescens' => 58692,
    'Amanita-citrina' => 63271,
    'Amanita-constricta' => 67355,
    'Amanita-flavoconia' => 125389,
    'Amanita-gemmata' => 58691,
    'Amanita-fulva' => 63027,
    'Amanita-jacksonii' => 204589,
    'Amanita-muscaria' => 48715,
    'Amanita-ocreata' => 67356,
    'Amanita-novinupta' => 57691,
    'Amanita-pantherina' => 48418,
    'Amanita-parcivolvata' => 500030,
    'Amanita-rubescens' => 67661,
    'Amanita-vaginata' => 55482,
    'Amanita-velosa' => 51314,
    # Order boletales, aka Boletes and Allies
    'Boletus-edulis' => 48701,
    'Boletus-subvelutipes' => 125367, 'Boletus-rubellus' => 62473, 'Suillus-cavipes' => 410601, 'Suillus-brevipes' => 63496, 'Leccinum-scabrum' => 63232,
    'Leccinum-aurantiacum' => 124085,
    'Xerocomellus-chrysenteron' => 438013,
    'Xerocomellus-dryophilus' => 438002,
    'Strobilomyces-floccopus' => 125719,
    'Tylopilus-plumbeoviolaceus' => 146681,
    'Tylopilus-felleus' => 63489,
    'Tylopilus-rubrobrunneus' => 352692,
    'Lycoperdon' => 48444,
    # Psathyrellaceae
    'Coprinellus-micaceus' => 56318,
    'Coprinellus-disseminatus' => 56314,
    'Psathyrella-candolleana' => 119968,
    'Panaeolus-papilionaceus' => 118263,
    'Parasola-lactea' => 337565,
    'Parasola-plicatilis' => 63583,
    'Panaeolus-foenisecii' => 902551,
    'Panaeolus-antillarum' => 348989,
    # Strophariaceae
    'Hypholoma-fasciculare' => 48767,
    'Hypholoma-capnoides' => 64071,
    'Hypholoma-lateritium' => 130203,
    # Gymnopilus
    'Gymnopilus-junonius' => 83196,
    'Gymnopilus-sapineus' => 118302,
    'Gymnopilus-ventricosus' => 348809,
    # Scalycaps
    'Pholiota-aurivella' => 124705,
    'Pholiota-squarrosa' => 153445,
    'Pholiota-squarrosoides' => 157728,
    # Leratiomyces
    'Leratiomyces-percevalii' => 129323,
    'Leratiomyces-ceres' => 121217,
    'Leratiomyces-erythrocephalus' => 53281,
    # Tricholomataceae
    'Entoloma-abortivum' => 70222,
    'Entoloma-ferruginans' => 208114,
    'Clitocybe-brunneocephala' => 208113,
    'Clitocybe-fragrans' => 118370,
    'Clitocybe-nebularis' => 63255,
    'Infundibulicybe-gibba' => 921916,
    'Lepista-nuda' => 351380,
    'Tricholoma-dryophilum' => 67345,
    'Tricholoma-terreum' => 341797,
    'Tricholoma-magnivelare' => 62483,
    'Tricholoma-matsutake' => 62486,
    # Webcaps
    'Cortinarius-caperatus' => 125364,
    'Cortinarius-iodes' => 154583,
    'Cortinarius-violaceus' => 124344,
    # Stropharia
    'Stropharia-rugosoannulata' => 119151,
    'Stropharia-ambigua' => 53284,
    'Stropharia-aeruginosa' => 55583,
    # Agrocybe
    'Agrocybe-putaminum' => 343465,
    'Agrocybe-praecox' => 118391,
    'Agrocybe-pediades' => 118393,
    # Coprinus
    'Coprinus-comatus' => 47392,
    'Coprinopsis-atramentaria' => 48521,
    'Coprinopsis-lagopus' => 55605,
    'Coprinopsis-variegata' => 362215,
    # Shaggy parasol
    'Chlorophyllum-brunneum' => 58693,
    'Chlorophyllum-rhacodes' => 56535,
    'Chlorophyllum-molybdites' => 117308
  }.freeze

  def self.download!
    total_photos = 0
    logs = File.new('./photos/log.txt', 'w')

    TAXA.each do |name, id|
      puts "Retrieving #{name} photos...."
      res = paginate(id, pages = 5)
      total_photos += res.count
      puts "Retrieved #{res.count} #{name} photos"
      logs.puts("#{name}, #{res.count}")

      # create the csv based on the taxon name
      small = File.new("./photos/small/#{name}.csv", 'w')
      medium = File.new("./photos/medium/#{name}.csv", 'w')
      large = File.new("./photos/large/#{name}.csv", 'w')

      puts 'Saving URLs to file...'
      res.map do |ob|
        photos = ob['photos']
        photos.each do |photo|
          small.puts(photo['small_url'])
          medium.puts(photo['medium_url'])
          large.puts(photo['large_url'])
        end
      end

      small.close()
      medium.close()
      large.close()
    end

    logs.puts("total, #{total_photos}")
  end

  private

  def self.path(taxon_id, page = 1)
    "https://www.inaturalist.org/observations?photos=true&taxon_id=#{taxon_id}" +
      "&quality_grade=research&per_page=200&page=#{page}"
  end

  def self.paginate(taxon_id, pages)
    all_pages = []
    (1..pages).each do |page|
      full_path = path(taxon_id, page)
      puts "GET #{full_path}, headers: #{HEADERS.inspect}"
      res = RestClient.get(full_path, HEADERS)
      all_pages.concat(JSON.parse(res))
      total_entries = res.headers.fetch(:x_total_entries).to_i
      puts "There should be #{total_entries} results for #{taxon_id}"
      break unless (total_entries / (200 * page)) > 0
    end

    all_pages
  end
end

puts MushroomData::TAXA.keys.map { |k| "'#{k}'" }.join(", ")
