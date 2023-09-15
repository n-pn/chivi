<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import cpos_info from '$lib/consts/cpos_info'
  import attr_info from '$lib/consts/attr_info'

  import { rel_time_vp } from '$utils/time_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import CposPicker from '$gui/parts/CposPicker.svelte'
  import AttrPicker from '$gui/parts/AttrPicker.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let form = data.form
  let prev = data.prev

  let form_stt = ''
  let form_msg = ''

  $: on_edit = prev

  let show_cpos_picker = false
  let show_attr_picker = false

  const action = '/_ai/terms/once'
  const method = 'PUT'

  const headers = { 'Content-type': 'application/json' }

  const reset_term = () => {
    if (prev) {
      form.vstr = prev.vstr
      form.cpos = prev.cpos
      form.attr = prev.attr
      form.plock = prev.plock
    } else {
      form.vstr = ''
      form.cpos = ''
      form.attr = ''
      form.plock = 1
    }
  }
  const submit_term = async () => {
    const body = { ...form, old_cpos: prev?.cpos, dname: data.dname }
    const init = { body: JSON.stringify(body), method, headers }
    const res = await fetch(action, init)

    console.log(body)
    form_msg = ''

    if (res.ok) {
      form_stt = 'ok'
      form_msg = 'Đã lưu từ vào hệ thống!'

      prev = await res.json()
      console.log(prev)
    } else {
      form_stt = 'err'
      form_msg = await res.text()
    }
  }

  $: min_privi = map_privi(data.dname)

  const map_privi = (dname: String) => {
    if (dname == 'regular') return 1
    if (dname.match(/^book|priv/)) return 0
    return 2
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
        <code>{form.cpos || '_'}</code>
        <span>{cpos_info[form.cpos || '_']?.name}</span>
      </button>
    </div>

    <div class="form-field">
      <label for="attr" class="form-label">Từ tính:</label>
      <button
        type="button"
        class="m-input"
        on:click={() => (show_attr_picker = !show_attr_picker)}>
        {#each form.attr.split(' ') as attr}
          {@const { desc } = attr_info[attr] || {}}
          <code data-tip={desc}>{attr}</code>
        {:else}
          <code>None</code>
        {/each}
      </button>
    </div>

    <div class="form-field">
      <label for="attr" class="form-label">Khóa sửa:</label>
      {#each [0, 1, 2] as plock}
        <label
          class="form-radio"
          class:_active={plock == form.plock}
          data-tip="Cần quyền hạn tối thiểu là {min_privi + plock} để sửa từ">
          <input type="radio" bind:group={form.plock} value={plock} />
          <SIcon name="plock-{plock}" iset="icons" />
          <span>Quyền hạn {min_privi + plock}</span>
        </label>
      {/each}
    </div>
  </div>

  {#if form_msg}
    <div class="form-msg _{form_stt}">{form_msg}</div>
  {/if}

  <footer class="foot">
    <button type="reset" class="m-btn _harmful" on:click={reset_term}>
      <SIcon name="arrow-back-up" />
      <span>Phục hồi</span>
    </button>
    <button type="button" class="m-btn _primary _fill" on:click={submit_term}>
      <SIcon name="send" />
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
    width: 5rem;
    padding-bottom: 0;
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

  code + code {
    margin-left: 0.25rem;
  }
</style>
