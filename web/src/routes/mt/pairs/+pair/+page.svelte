<script lang="ts">
  import { dnames } from '$lib/consts/pair_dicts'

  import { get_user, zfrom } from '$lib/stores'
  const _user = get_user()

  import attr_info from '$lib/consts/attr_info'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import AttrPicker from '$gui/parts/AttrPicker.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let zform = data.zform

  let form_stt = ''
  let form_msg = ''

  let select_a_attr = false
  let select_b_attr = false

  const action = '/_ai/zvpairs/once'
  const method = 'PUT'

  const headers = { 'Content-type': 'application/json' }

  const submit_term = async () => {
    const init = { body: JSON.stringify(zform), method, headers }
    const res = await fetch(action, init)

    form_msg = ''

    if (res.ok) {
      form_stt = 'ok'
      form_msg = 'Đã lưu từ vào hệ thống!'
    } else {
      form_stt = 'err'
      form_msg = await res.text()
    }
  }

  $: a_attrs = zform.a_attr ? zform.a_attr.split(' ') : []
  $: b_attrs = zform.b_attr ? zform.b_attr.split(' ') : []
</script>

<article class="article m-article">
  <header>
    <h1 class="h2">Thêm sửa nghĩa cặp từ</h1>
  </header>

  <div class="body">
    <div class="form-field">
      <label for="dname" class="form-label">Cặp từ:</label>

      {#each Object.entries(dnames) as [value, label]}
        {@const _active = value == zform.dname}
        <button
          type="button"
          class="m-chip _primary"
          class:_active
          on:click={() => (zform.dname = value)}>
          <span>{label}</span>
          {#if _active}<SIcon name="check" />{/if}
        </button>
      {/each}
    </div>

    <div class="form-group">
      <div class="form-field">
        <label for="a_key" class="form-label">Trung A:</label>
        <input
          class="m-input"
          type="text"
          name="a_key"
          lang="zh"
          placeholder="Tiếng Trung"
          bind:value={zform.a_key} />
      </div>

      <div class="form-field">
        <label for="vstr" class="form-label">Nghĩa A:</label>
        <input
          class="m-input"
          type="text"
          name="vstr"
          lang="vi"
          required
          placeholder="Nghĩa của từ"
          bind:value={zform.a_vstr} />
      </div>

      <div class="form-field">
        <label for="attr" class="form-label">Từ tính A:</label>
        <button
          type="button"
          class="m-input _attr"
          on:click={() => (select_a_attr = !select_a_attr)}>
          {#each a_attrs as attr}
            {@const { desc } = attr_info[attr] || {}}
            <code data-tip={desc}>{attr}</code>
          {:else}
            <code>-</code>
          {/each}
        </button>
      </div>
    </div>

    <div class="form-group">
      <div class="form-field">
        <label for="b_key" class="form-label">Trung B:</label>
        <input
          class="m-input"
          type="text"
          name="b_key"
          lang="zh"
          placeholder="Tiếng Trung"
          bind:value={zform.b_key} />
      </div>
      <div class="form-field">
        <label for="vstr" class="form-label">Nghĩa B:</label>
        <input
          class="m-input"
          type="text"
          name="vstr"
          lang="vi"
          placeholder="Có thể để trắng"
          bind:value={zform.b_vstr} />
      </div>

      <div class="form-field">
        <label for="attr" class="form-label">Từ tính B:</label>
        <button
          type="button"
          class="m-input _attr"
          on:click={() => (select_b_attr = !select_b_attr)}>
          {#each b_attrs as attr}
            {@const { desc } = attr_info[attr] || {}}
            <code data-tip={desc}>{attr}</code>
          {:else}
            <code>-</code>
          {/each}
        </button>
      </div>
    </div>
  </div>

  {#if form_msg}
    <div class="form-msg _{form_stt}">{form_msg}</div>
  {/if}

  <footer class="foot">
    <button type="submit" class="m-btn _primary _fill _lg">
      <SIcon name="send" />
      <span>Lưu cặp từ</span>
    </button>
  </footer>
</article>

{#if select_a_attr}
  <AttrPicker bind:output={zform.a_attr} bind:actived={select_a_attr} />
{/if}

{#if select_b_attr}
  <AttrPicker bind:output={zform.b_attr} bind:actived={select_b_attr} />
{/if}

<style lang="scss">
  .body {
    display: block;
    width: 100%;
    overflow-x: auto;
    white-space: nowrap;
  }

  .form-field {
    @include flex-cy;
    gap: 0.5rem;
  }

  .form-label {
    padding-bottom: 0;
  }

  .form-group {
    display: flex;
    gap: 0.75rem;

    .form-field {
      flex-direction: column;
      align-items: flex-start;
    }
  }

  .form-radio {
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    @include fgcolor(tert);

    & + & {
      margin-left: 0.25rem;
    }

    &._active {
      @include fgcolor(primary);
    }

    input[type='radio'] {
      margin-right: 0.25rem;
    }
  }

  .foot {
    display: flex;
    gap: 0.5rem;
  }

  .m-chip {
    padding-left: 0.75em;
    padding-right: 0.75em;
  }
  // ._attr {
  //   width: 10rem;
  // }

  code + code {
    margin-left: 0.25rem;
  }
</style>
