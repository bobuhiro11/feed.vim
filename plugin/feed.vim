" requirements: webapi-vim, open-browser.vim

let s:links = {'0':'hoge'}
"let g:feedvim_urls = [ 'http://togetter.com/rss/hot', 'http://blog.livedoor.jp/dqnplus/index.rdf', 'http://blog.livedoor.jp/ts1209/index.rdf']

function! FeedvimOpenLink()
  let s:url = s:links[ line('.') ]
  execute "OpenBrowser" s:url
endfunction

" buffer operation
augroup MyGroup
  autocmd!
  autocmd FileType feed.vim.buffer nnoremap <buffer> o :call FeedvimOpenLink()<CR>
  autocmd FileType feed.vim.buffer setlocal noswapfile
augroup END

function! s:get_title(url)
  let dom = webapi#xml#parseURL(a:url)
  let i=0
  let title='no title'

  while i < 10
    if dom['name'] == 'title'
      let title = dom['child'][0]
      break
    endif
    let dom = dom['child'][1]
    let i += 1
  endwhile

  return title
endfunction

function! s:write(s) abort
  call append(line("$"), a:s)
endfunction

function! FeedvimOpenBuffer()
  " change buffer
  let bufnum = bufnr('feed.vim.buffer')
  if bufnum == -1
    enew
  else
    execute bufnum.'buffer'
    execute '%d'
  endif

  " set buffer parameter
  set filetype=feed.vim.buffer
  set buftype=nofile
  file 'feed.vim.buffer'

  " output
  for url in g:feedvim_urls

    " title
    call s:write("")
    call s:write("# ".s:get_title(url))
    call s:write("")

    " item
    for item in webapi#feed#parseURL(url)
      "call s:write("* ".item.title.' - '.item.link)
      call s:write("* ".item.title)
      let s:links[ ''.line('$').'' ] = item.link
    endfor
  endfor
endfunction

command! Feedvim call FeedvimOpenBuffer()
