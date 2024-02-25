# mywords.nvim
<a href="https://dotfyle.com/plugins/dwrdx/mywords.nvim">
	<img src="https://dotfyle.com/plugins/dwrdx/mywords.nvim/shield?style=flat" />
</a>

Highlight words with different colors in neovim. When all the configured colors has been used, the first highlight 
will be cleared automatically and used for the next new highlight, you don't have to clear old highlights that 
you don't care anymore.

![mywords-nvim-demo](https://i.ibb.co/gvk66DM/mywords-nvim-demo.gif)

## How to install

Recommend to use `vim-plug`

```
Plug 'dwrdx/mywords.nvim' 
```


## How to use

configuire your own key mappings in init.vim

``` 
map <silent> <leader>m :lua require'mywords'.hl_toggle()<CR>
map <silent> <leader>c :lua require'mywords'.uhl_all()<CR>
```
