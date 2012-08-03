$ ->
  formRoot = $('#name-compare')
  path = window.location.pathname

  formRoot.find('button.submit').click (e) ->
    responseField = $('#response .results')
    dataTable = responseField.find 'table'
    dataList = responseField.find 'textarea'
    status = responseField.find '.status'
    toggler = $('#response .js-data-toggler')

    status.html 'Working&hellip;'
    dataTable.hide()
    dataList.hide()

    toggler.hide().find('li.active').removeClass 'active'
    toggler.find('li').eq(0).addClass 'active'

    t = $('#transliteration').is ':checked'
    l = $('#lowercasing').is ':checked'
    dT = parseFloat($('#directThreshold').val())
    iT = parseFloat($('#initialsThreshold').val())
    n = $('#names').val()

    if isNaN(dT) or dT < 0
      dT = 0
    else if dT > 100
      dT = 100

    if isNaN(iT) or iT < 0
      iT = 0
    else if iT > 100
      iT = 100

    $('#directThreshold').val dT
    $('#initialsThreshold').val iT

    $.ajax
      type: 'post'
      url: path+'api'

      contentType: 'application/json; charset=utf-8'
      dataType: 'json'

      data:
        JSON.stringify
          transliteration: t
          lowercasing: l
          directThreshold: dT / 100
          initialsThreshold: iT / 100
          names: n

      success: (response) ->
        status.text ''

        table = dataTable.find 'tbody'
        table.find('tr').remove()
        dataList.html ''

        i = 1
        for row in response
          c = row.comparisonDecision
          status = if c.decision is 'Yes' then 'label-success' else if c.decision is 'No' then 'label-important' else 'label-warning'
          decision = "<span class=\"label #{status}\">#{c.decision}</span>"
          perc = (c.percentage * 100).toFixed 2
          desc = c.description

          sO = row.src.original
          sP = row.src.processed
          dO = row.dst.original
          dP = row.dst.processed

          table.append "<tr><td class=\"center\">#{i}</td><td>#{sO}</td><td>#{dO}</td><td class=\"center\">#{desc}</td><td class=\"right\">#{perc}%</td><td class=\"center\">#{decision}</td></tr>"
          dataList.append "#{sO}\t#{sP}\t#{dO}\t#{dP}\t#{c.decision}\t#{desc}\t#{perc}%\r\n"
          i++

        dataTable.show()
        dataList.attr 'rows', response.length+1
        toggler.show()
        return

      error: (response) ->
        responseField.find('.status').removeClass('muted').html '<span class="label label-important">Error '+response.status+': '+response.statusText+'</span>'
        return
    false

  $('#response .js-data-toggler a').click ->
    $(@).parents('ul').children('li').removeClass 'active'
    $(@).parent().addClass 'active'
    target = $(@).attr 'href'
    $('#response .js-resultlist').hide()
    $(target).show()
    false

  return
