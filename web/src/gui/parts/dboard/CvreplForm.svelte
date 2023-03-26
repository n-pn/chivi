<script lang="ts">
  import { api_call } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import MdForm from '$gui/molds/MdForm.svelte'

  export let cvpost_id = 0
  export let cvrepl_id = 0
  export let dtrepl_id = 0
  export let disabled = false

  export let on_destroy = (new_repl?: CV.Cvrepl) => {
    if (new_repl) window.location.reload()
  }

  $: on_edit = cvrepl_id > 0

  $: [action, method] =
    dtrepl_id > 0
      ? [`/_db/tposts/${dtrepl_id}`, 'PATCH']
      : [`/_db/tposts`, 'POST']

  let form = { input: '', repl_id: dtrepl_id || -cvpost_id, post_id: cvpost_id }
  $: if (cvrepl_id > 0) load_form(cvrepl_id)

  let error = ''

  async function load_form(id: number) {
    const api_url = `/_db/tposts/${id}/detail`
    const api_res = await fetch(api_url)
    if (api_res.ok) form = await api_res.json()
  }

  async function submit() {
    error = ''

    try {
      const new_repl = await api_call(action, form, method)
      form.input = ''
      on_destroy(new_repl as CV.Cvrepl)
    } catch (ex) {
      error = ex.body?.message
    }
  }

  $: placeholder = disabled
    ? 'Bạn cần đăng nhập để thêm bình luận'
    : 'Nội dung bình luận'
</script>

<form class="repl-form" {action} {method} on:submit|preventDefault={submit}>
  <MdForm bind:value={form.input} name="input" {disabled} {placeholder}>
    <svelte:fragment slot="footer">
      {#if error}
        <div class="form-msg _err">{error}</div>
      {/if}

      <footer>
        {#if cvrepl_id || dtrepl_id}
          <button type="button" class="m-btn _sm" on:click={() => on_destroy()}>
            <SIcon name="x" />
          </button>
        {/if}

        <button
          type="submit"
          class="m-btn _primary _fill _sm"
          disabled={disabled || form.input.length < 3}
          on:click|preventDefault={submit}>
          <SIcon name="send" />
          <span
            >{on_edit ? 'Sửa' : 'Thêm'}
            {dtrepl_id ? 'trả lời' : 'bình luận'}</span>
        </button>
      </footer>
    </svelte:fragment>
  </MdForm>
</form>

<style lang="scss">
  form {
    display: block;
    width: 100%;
  }

  footer {
    padding-top: 0.75rem;
    @include flex($center: vert, $gap: 0.5rem);

    justify-content: right;
  }

  ._err {
    line-height: 1.5rem;
    margin-top: 0.25rem;
    margin-bottom: -0.5rem;
    font-style: italic;
    @include ftsize(sm);
    @include fgcolor(harmful, 5);
  }
</style>
