<script lang="ts">
  import { session } from '$app/stores'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import MdForm from '$gui/molds/MdForm.svelte'

  export let cvpost_id = '0'
  export let cvrepl_id = 0
  export let dtrepl_id = 0

  export let on_destroy = (dirty = false) => {
    if (dirty) window.location.reload()
  }

  let on_edit = cvrepl_id > 0
  let api_url = gen_api_url(cvpost_id)

  let form = { input: '', itype: 'md', rp_id: dtrepl_id }
  $: if (cvrepl_id > 0) load_form(cvrepl_id)

  let error = ''

  async function load_form(id: number) {
    const api_url = `/api/tposts/${id}/detail`
    const api_res = await fetch(api_url)
    const payload = await api_res.json()
    if (api_res.ok) form = payload.props
  }

  function gen_api_url(cvpost_id: string) {
    let base_url = '/api/tposts'
    if (cvrepl_id) return base_url + '/' + cvrepl_id
    return base_url + '?cvpost=' + cvpost_id
  }

  async function submit() {
    error = ''

    const api_res = await fetch(api_url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(form),
    })

    const payload = await api_res.json()
    if (!api_res.ok) {
      error = payload.error
      return
    } else {
      form.input = ''
      on_destroy(true)
    }
  }
</script>

{#if $session.privi >= 0}
  <cvrepl-form>
    <form action={api_url} method="POST" on:submit|preventDefault={submit}>
      <form-field class="body">
        <MdForm
          bind:value={form.input}
          name="input"
          placeholder="Nội dung bình luận" />
      </form-field>

      {#if error}
        <form-error>{error}</form-error>
      {/if}

      <form-foot>
        {#if cvrepl_id || dtrepl_id}
          <button
            type="button"
            class="m-btn _sm"
            on:click={() => on_destroy(false)}>
            <SIcon name="x" />
          </button>
        {/if}

        <button
          type="submit"
          class="m-btn _primary _fill _sm"
          on:click|preventDefault={submit}>
          <SIcon name="send" />
          <span
            >{on_edit ? 'Lưu' : 'Gửi'}
            {dtrepl_id ? 'trả lời' : 'bình luận'}</span>
        </button>
      </form-foot>
    </form>
  </cvrepl-form>
{:else}
  <div class="disable">Đăng nhập để bình luận</div>
{/if}

<style lang="scss">
  cvrepl-form {
    display: block;
  }

  form {
    display: block;
    // width: 100%;
  }

  form-field {
    display: block;
    margin-top: 0.75rem;
  }

  form-foot {
    padding-top: 0.75rem;
    @include flex($center: vert, $gap: 0.5rem);

    justify-content: right;
  }

  cvrepl-form {
    display: block;
    margin-top: 0.25rem;
  }

  form-error {
    display: block;
    line-height: 1.5rem;
    margin-top: 0.25rem;
    margin-bottom: -0.5rem;
    font-style: italic;
    @include ftsize(sm);
    @include fgcolor(harmful, 5);
  }

  .disable {
    @include fgcolor(tert);
    font-style: italic;
  }
</style>
