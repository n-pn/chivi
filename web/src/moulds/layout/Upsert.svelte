<script>
  import MIcon from '$mould/shared/MIcon.svelte'

  export let actived = false

  export let dict_id = 0
  export let zh_term = ''

  let props = {}

  $: vi_main = props.vi_list[0] || props.suggest[0]
  $: vi_rest = props.vi_list.slice(1)

  let vi_focus

  $: if (zh_term) {
    fetch(`/api/upsert?i=${zh_term}`).then(res => (props = res.json()))
  }

  $: links = [
    { site: 'iCIBA', href: `http://www.iciba.com/${zh_term}` },
    {
      site: 'Google Translation',
      href: `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=en&text=${zh_term}/`,
    },
    {
      site: 'Google Search',
      href: `http://www.google.com/search?q=${zh_term}`,
    },
    {
      site: 'Baidu Fanyi',
      href: `https://fanyi.baidu.com/#zh/en/${zh_term}`,
    },
    {
      site: 'Baidu Baike',
      href: `https://baike.baidu.com/item/${zh_term}`,
    },
  ]

  function active() {
    actived = true
    vi_focus.focus()
  }

  function cancel() {
    actived = false
  }

  function update() {
    fetch(`/api/upsert`, {
      method: 'post',
      body: JSON.stringify({ zh_term, vi_list: props.vi_list, dict_id }),
    })

    cancel()
  }

  function remove() {
    fetch(`/api/dicts/${dict_id}/delete`, {
      method: 'delete',
      body: JSON.stringify({ keys: [zh_term] }),
    })
    cancel()
  }

  function add_viet(viet) {
    props.vi_list.unshift(viet)
    props = props
  }

  function remove_viet(viet) {
    props.vi_list = props.vi_list.filter(x => x == viet)
    props.suggest.push(viet)
    props = props
  }
</script>

{#if actived}
  <upsert-wrapper>
    <upsert-dialog>
      <upsert-header>
        <upsert-title>Upsert</upsert-title>
        <button on:click={cancel}>
          <MIcon name="x" />
        </button>
      </upsert-header>

      <upsert-body>
        <upsert-input>
          <label for="zh_term" class="label">Input:</label>
          <input type="text" name="zh_term" bind:value={zh_term} />
        </upsert-input>

        <upsert-translit>
          <translit-hanviet>{props.hanviet}</translit-hanviet>
          <translit-pinyins>{props.pinyins}</translit-pinyins>
        </upsert-translit>

        <upsert-vietphrase>
          <viet-list>
            <viet-item>
              <input
                type="text"
                class="tran-input"
                bind:value={vi_main}
                bind:this={vi_focus} />
              <button on:click={() => remove_viet(vi_main)}>
                <MIcon name="x" />
              </button>
            </viet-item>

            {#each vi_rest as viet}
              <viet-item>
                <input type="text" class="tran-input" bind:value={viet} />
                <button on:click={() => remove_viet(viet)}>
                  <MIcon name="x" />
                </button>
              </viet-item>
            {/each}
          </viet-list>
        </upsert-vietphrase>
      </upsert-body>

      <upsert-sidebar>
        <upsert-links>
          {#each links as link}
            <a href={link.href} target="_blank" rel="noopener noreferrer">
              {link.site}
            </a>
          {/each}
        </upsert-links>

        <upsert-suggest>
          {#each props.suggest as viet}
            <suggest-item on:click={() => add_viet(viet)} />
          {/each}
        </upsert-suggest>
      </upsert-sidebar>

      <upsert-footer>
        <button class="button" on:click={update}>Update</button>
        <button class="button" on:click={remove}>Remove</button>
        <button class="button" on:click={cancel}>Cancel</button>
      </upsert-footer>
    </upsert-dialog>
  </upsert-wrapper>
{/if}
