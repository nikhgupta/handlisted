module AddProductHelpers
  def add_product(user, url)
    pid, url = PRODUCTS_LIST[url][:pid], PRODUCTS_LIST[url][:url]
    ProductScraperJob.perform_async user.id, url
    ProductScraperJob.drain
    product = Product.find_by(pid: pid)
    expect(product).to be_persisted
    product
  end

  def add_product_via_sitewide_search(url)
    url = PRODUCTS_LIST[url][:url] if url.is_a?(Symbol)
    find('#product_search').tap do |box|
      box.set url
      box.native.send_keys :Enter
    end
    wait_for_traffic
  end
  alias :search_using_sitewide_search :add_product_via_sitewide_search

  def progress_status
    # sleep 1     # progress status is reflected with some slight delay
    bar = find("header .progress-bar:not([aria-valuenow='0'])")
    bar["aria-valuenow"].to_i if bar
  end

  def click_for_product_info_modal(product)
    selector = card_selector_for(product) + " .image-container"
    find(selector).trigger("click")
  end

  # Add a product by given URL (or symbol), ensures that the Queued status is
  # reflected, and optionally, accepts a block to execute before the real
  # execution of job.
  #
  def add_product_via_search_and_perform(url, &block)
    add_product_via_sitewide_search(url)
    # OPTIMIZE: commenting the next two lines will save 1-3 seconds of test runs
    expect(page).to have_selector('header .active.progress-bar-dark')
    expect(progress_status).to be >= 10
    expect(ProductScraperJob.jobs.size).to eq 1
    if block_given?
      method = ProductScraper.method(:fetch)
      allow(ProductScraper).to receive(:fetch) do |args|
        yield
        method.call(*args)
      end
    end
    ProductScraperJob.drain
  ensure
    wait_for_traffic
  end

  def card_selector_for(product, card: :default)
    hash = Digest::MD5.hexdigest product.url_hash
    selector = "-#{card}" if card && card != :default
    "#productCard#{selector}-#{hash}"
  end

  def toggle_like_for_product(*args)
    selector = card_selector_for(*args) + " a.product-like"
    find(selector).trigger 'click'
    wait_for_traffic
  end

  def like_status_for(*args)
    selector = card_selector_for(*args) + " a.product-like"
    find(selector)['class'].include? 'active'
  end
end
