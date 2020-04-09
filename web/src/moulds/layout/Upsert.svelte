<script>
  import MIcon from '$mould/shared/MIcon.svelte'

  export let actived = false

  export let dic = 0
  export let key = ''

  let props = {}

  $: vi_main = props.val[0] || props.suggest[0]
  $: vi_rest = props.val.slice(1)

  let vi_focus

  $: if (key) reload(key)

  async function reload(key) {
    const res = await fetch(`/api/inspect?k=${key}`)
    const data = await res.json()
    props = data
  }

  $: links = [
    { site: 'iCIBA', href: `http://www.iciba.com/${key}` },
    {
      site: 'Google Translation',
      href: `https://translate.google.com/#view=home&op=translate&sl=zh-CN&tl=en&text=${key}/`,
    },
    {
      site: 'Google Search',
      href: `http://www.google.com/search?q=${key}`,
    },
    {
      site: 'Baidu Fanyi',
      href: `https://fanyi.baidu.com/#zh/en/${key}`,
    },
    {
      site: 'Baidu Baike',
      href: `https://baike.baidu.com/item/${key}`,
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
      body: JSON.stringify({ key, val: props.val, dic }),
    })

    cancel()
  }

  function remove() {
    fetch(`/api/dicts/${dic}`, {
      method: 'delete',
      body: JSON.stringify({ keys: [key] }),
    })
    cancel()
  }

  function add_viet(viet) {
    props.val.unshift(viet)
    props = props
  }

  function remove_viet(viet) {
    props.val = props.val.filter(x => x == viet)
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
          <label for="key" class="label">Input:</label>
          <input type="text" name="key" bind:value={key} />
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
                <MIcon m-icon="x" />
              </button>
            </viet-item>

            {#each vi_rest as viet}
              <viet-item>
                <input type="text" class="tran-input" bind:value={viet} />
                <button on:click={() => remove_viet(viet)}>
                  <MIcon m-icon="x" />
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
