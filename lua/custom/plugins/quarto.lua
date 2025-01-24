return {
  {
    'quarto-dev/quarto-nvim',
    dev = false,
    dependencies = {
      'jmbuhr/otter.nvim',
    },
    ft = { 'quarto', 'markdown' },
    config = function()
      require('quarto').setup {
        lspFeatures = {
          languages = { 'python' },
          chunks = 'all',
          diagnostics = {
            enabled = true,
          },
          completions = {
            enabled = true,
          },
        },
        codeRunner = {
          enabled = true,
          default_method = 'molten',
          ft_runners = {
            python = 'molten',
          },
        },
      }
      local runner = require 'quarto.runner'
      vim.keymap.set('n', '<leader>rc', runner.run_cell, { desc = 'run cell', silent = true })
      vim.keymap.set('n', '<leader>ra', runner.run_above, { desc = 'run cell and above', silent = true })
      vim.keymap.set('n', '<leader>rA', runner.run_all, { desc = 'run all cells', silent = true })
      vim.keymap.set('n', '<leader>rl', runner.run_line, { desc = 'run line', silent = true })
      vim.keymap.set('v', '<leader>r', runner.run_range, { desc = 'run visual range', silent = true })
      vim.keymap.set('n', '<leader>RA', function()
        runner.run_all(true)
      end, { desc = 'run all cells of all languages', silent = true })
    end,
  },
  { -- send code from python/r/qmd documets to a terminal or REPL
    -- like ipython, R, bash
    'jpalardy/vim-slime',
    dev = false,
    init = function()
      vim.b['quarto_is_python_chunk'] = false
      Quarto_is_in_python_chunk = function()
        require('otter.tools.functions').is_otter_language_context 'python'
      end

      vim.cmd [[
      let g:slime_dispatch_ipython_pause = 100
      function SlimeOverride_EscapeText_quarto(text)
      call v:lua.Quarto_is_in_python_chunk()
      if exists('g:slime_python_ipython') && len(split(a:text,"\n")) > 1 && b:quarto_is_python_chunk && !(exists('b:quarto_is_r_mode') && b:quarto_is_r_mode)
      return ["%cpaste -q\n", g:slime_dispatch_ipython_pause, a:text, "--", "\n"]
      else
      if exists('b:quarto_is_r_mode') && b:quarto_is_r_mode && b:quarto_is_python_chunk
      return [a:text, "\n"]
      else
      return [a:text]
      end
      end
      endfunction
      ]]

      vim.g.slime_target = 'neovim'
      vim.g.slime_no_mappings = true
      vim.g.slime_python_ipython = 1
    end,
    config = function()
      vim.g.slime_input_pid = false
      vim.g.slime_suggest_default = true
      vim.g.slime_menu_config = false
      vim.g.slime_neovim_ignore_unlisted = true

      local function mark_terminal()
        local job_id = vim.b.terminal_job_id
        vim.print('job_id: ' .. job_id)
      end

      local function set_terminal()
        vim.fn.call('slime#config', {})
      end
      vim.keymap.set('n', '<leader>cm', mark_terminal, { desc = '[m]ark terminal' })
      vim.keymap.set('n', '<leader>cs', set_terminal, { desc = '[s]et terminal' })
    end,
  },
  {
    'GCBallesteros/jupytext.nvim',
    opts = {
      custom_language_formatting = {
        python = {
          extension = 'md',
          style = 'markdown',
          force_ft = 'markdown',
        },
      },
    },
  },
}
