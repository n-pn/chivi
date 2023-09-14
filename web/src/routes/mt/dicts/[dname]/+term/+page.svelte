<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { rel_time_vp } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import CposPicker, { cpos_map } from '$gui/parts/CposPicker.svelte'
  import AttrPicker, { attr_map } from '$gui/parts/AttrPicker.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let form = data.form
  let prev = data.prev
  let _err = ''

  $: on_edit = prev

  let show_cpos_picker = false
  let show_attr_picker = false

  const action = '/_ai/terms/once'
  const method = 'PUT'

  const headers = { 'Content-type': 'application/json' }

  const submit_term = async () => {
    const body = { ...form, old_cpos: prev?.cpos }
    const init = { body: JSON.stringify(body), method, headers }
    const res = await fetch(action, init)

    if (res.ok) prev = await res.json()
    else _err = await res.text()
  }
</script>

<article class="article m-article">
  <header>
    <h1 class="h2">Thêm sửa từ</h1>
    {#if prev}
      <p>
        Từ đã được thêm/sửa bởi <cv-user>@{prev.uname}</cv-user>, thời gian:
        <time>{rel_time_vp(prev.mtime)}</time>
      </p>
    {/if}
  </header>

  <div class="body">
    <div class="form-field">
      <label for="zstr" class="form-label">Trung:</label>
      <input
        type="text"
        name="zstr"
        lang="zh"
        class="m-input"
        bind:value={form.zstr}
        disabled={!!prev} />
    </div>

    <div class="form-field">
      <label for="vstr" class="form-label">Nghĩa:</label>
      <input
        type="text"
        name="vstr"
        lang="vi"
        class="m-input"
        bind:value={form.vstr} />
    </div>

    <div class="form-field">
      <label for="cpos" class="form-label">Từ loại:</label>
      <button
        type="button"
        class="m-input"
        on:click={() => (show_cpos_picker = !show_cpos_picker)}>
        {cpos_map[form.cpos || '_']?.name} ({form.cpos || '_'})
      </button>
    </div>

    <div class="form-field">
      <label for="attr" class="form-label">Từ tính:</label>
      <button
        type="button"
        class="m-input"
        on:click={() => (show_attr_picker = !show_attr_picker)}>
        {form.attr || '-'}
      </button>
    </div>
  </div>

  <footer class="foot">
    <button type="button" class="m-btn _primary _fill" on:click={submit_term}>
      <span>{on_edit ? 'Sửa' : 'Thêm'} từ</span>
    </button>
  </footer>
</article>

{#if show_cpos_picker}
  <CposPicker bind:output={form.cpos} bind:actived={show_cpos_picker} />
{/if}

{#if show_attr_picker}
  <AttrPicker bind:output={form.attr} bind:actived={show_attr_picker} />
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
    width: 6rem;
  }
</style>
