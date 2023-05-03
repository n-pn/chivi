<script lang="ts">
  import { api_call } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import MdForm from '$gui/molds/MdForm.svelte'

  export let form = {
    itext: '',
    level: 0,

    gdroot: '',
    gdrepl: 0,
    torepl: 0,
    touser: 0,
  }

  export let placeholder = 'Nội dung bình luận'
  export let disabled = false

  export let on_destroy = (new_repl?: CV.Gdrepl) => {
    if (new_repl) window.location.reload()
  }

  let action = `/_db/mrepls/create`
  let method = `POST`

  $: if (form.gdrepl > 0) {
    load_form(form.gdrepl)
    action = `/_db/mrepls/update/${form.gdrepl}`
    method = 'PATCH'
  }

  let error = ''

  async function load_form(id: number) {
    const api_url = `/_db/mrepls/edit/${id}`
    const api_res = await fetch(api_url)
    if (api_res.ok) form = await api_res.json()
  }

  async function submit(evt: Event) {
    evt.preventDefault()
    error = ''

    try {
      const new_repl = await api_call(action, form, method)
      form.itext = ''
      on_destroy(new_repl as CV.Gdrepl)
    } catch (ex) {
      error = ex.body?.message
    }
  }
</script>

<form class="repl-form" {action} {method} on:submit={submit}>
  <MdForm
    bind:value={form.itext}
    name="itext"
    {disabled}
    placeholder={disabled
      ? 'Bạn cần đăng nhập để thêm bình luận'
      : placeholder}>
    <svelte:fragment slot="footer">
      {#if error}<div class="form-msg _err">{error}</div>{/if}

      <footer>
        {#if form.gdrepl || form.torepl}
          <button type="button" class="m-btn _sm" on:click={() => on_destroy()}>
            <SIcon name="x" />
          </button>
        {/if}

        <button
          type="submit"
          class="m-btn _primary _fill _sm"
          disabled={disabled || form.itext.trim().length < 3}>
          <SIcon name="send" />
          <span>Lưu {form.torepl ? 'trả lời' : 'bình luận'}</span>
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
