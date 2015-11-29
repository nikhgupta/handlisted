ready = ->
  $('[data-pages="search"]').search
    searchField: '#overlay-search'
    closeButton: '.overlay-close'
    suggestions: '#overlay-suggestions'
    brand: '.brand'
    onSearchSubmit: (searchString) ->
      console.log 'Search for: ' + searchString
      return
    onKeyEnter: (searchString) ->
      console.log 'Live search for: ' + searchString
      searchField = $('#overlay-search')
      searchResults = $('.search-results')

      ###
          Do AJAX call here to get search results
          and update DOM and use the following block 
          'searchResults.find('.result-name').each(function() {...}'
          inside the AJAX callback to update the DOM
      ###

      # Timeout is used for DEMO purpose only to simulate an AJAX call
      clearTimeout $.data(this, 'timer')
      searchResults.fadeOut 'fast'
      # hide previously returned results until server returns new results
      wait = setTimeout((->
        searchResults.find('.result-name').each ->
          if searchField.val().length != 0
            $(this).html searchField.val()
            searchResults.fadeIn 'fast'
            # reveal updated results
      ), 500)
      $(this).data 'timer', wait

$ -> ready()
