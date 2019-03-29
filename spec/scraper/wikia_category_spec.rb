RSpec.describe EnterRockstar::Scraper::Wikia do
  context 'category page scraping' do
    let(:category_name) { 'power_metal' }
    let(:url) { '/wiki/Category:Genre/Power_Metal' }
    let(:json_source) { file_fixture('spec/fixtures/wikia_power_metal.json.gz').read }
    let(:expected_tree) { JSON.parse Zlib::GzipReader.new(StringIO.new(json_source)).read }

    let(:scraper) do
      EnterRockstar::Scraper::Wikia.new(
        category_name: category_name,
        url: url,
        data_dir: 'spec/fixtures'
      )
    end

    describe '#parse_category' do
      it 'gets a hash tree from the wikia page', :vcr do
        scraper.parse_category(test_limit: true)

        expect(scraper.tree).to eq expected_tree
      end
    end

    describe '#load_saved_json' do
      it 'reads the saved json gzip' do
        scraper.load_saved_json

        expect(scraper.tree).to eq expected_tree
      end

      context 'if gzipped json is not available' do
        let(:scraper) do
          EnterRockstar::Scraper::Wikia.new(
            category_name: 'power_metal_ungzipped',
            url: url,
            data_dir: 'spec/fixtures'
          )
        end

        it 'tries to fall back on ungzipped json' do
          scraper.load_saved_json

          expect(scraper.tree).to eq expected_tree
        end
      end

      context 'if no file found' do
        let(:scraper) do
          EnterRockstar::Scraper::Wikia.new(
            category_name: 'wrong_category_name',
            url: url,
            data_dir: 'spec/fixtures'
          )
        end

        it 'raises IOError' do
          expect { scraper.load_saved_json }.to raise_error IOError
        end
      end
    end
  end
end
