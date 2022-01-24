<script context="module">
  import { writable } from 'svelte/store'
  import { dtpost_form as form } from '$lib/stores'

  export const ctrl = {
    ...writable({ id: 0, actived: false }),
    show(id = 0, rp_id = 0) {
      form.init(id, rp_id)
      ctrl.set({ id, actived: true })
    },
    hide() {
      ctrl.set({ actived: false })
    },
  }
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'
  import MdForm from '$molds/MdForm.svelte'
  import Gmodal from '$molds/Gmodal.svelte'

  export let dtopic = {}
  export let on_destroy = () => window.location.reload()

  $: on_edit = $ctrl.id > 0
  $: api_url = gen_api_url(dtopic.id, on_edit)

  let error = ''

  function gen_api_url(dtopic_id, on_edit) {
    let base_url = '/api/tposts'
    if (on_edit) return base_url + '/' + $ctrl.id
    return base_url + '?dtopic=' + dtopic_id
  }

  async function submit() {
    error = await form.submit(api_url)
    if (error) return

    on_destroy()
    ctrl.hide()
  }
</script>

<Gmodal actived={$ctrl.actived} on_close={ctrl.hide}>
  <dtpost-form>
    <dtpost-head>
      <head-title>{on_edit ? 'Sửa' : 'Thêm'} bình luận</head-title>

      <button type="button" data-kbd="esc" class="x-btn" on:click={ctrl.hide}>
        <SIcon name="x" />
      </button>
    </dtpost-head>

    <form action={api_url} method="POST" on:submit|preventDefault={submit}>
      <form-field class="body">
        <MdForm
          bind:value={$form.input}
          name="input"
          placeholder="Nội dung bình luận" />
      </form-field>

      {#if error}
        <form-error>{error}</form-error>
      {/if}

      <form-foot>
        <button
          type="submit"
          class="m-btn _primary _fill"
          on:click|preventDefault={submit}>
          <SIcon name="send" />
          <!-- prettier-ignore -->
          <span>{on_edit ? 'Lưu' : 'Gửi'} bình luận</span>
        </button>
      </form-foot>
    </form>
  </dtpost-form>
</Gmodal>

<style lang="scss">
  dtpost-form {
    display: block;
    width: 40rem;
    max-width: 100%;
    padding: 0.75rem;

    @include bdradi();
    @include shadow(1);
    @include bgcolor(secd);

    @include tm-dark {
      @include linesd(--bd-soft, $ndef: false, $inset: false);
    }
  }

  dtpost-head {
    display: flex;

    :global(svg) {
      width: 1rem;
      height: 1rem;
      margin-top: -0.125rem;
    }
  }

  .x-btn {
    @include fgcolor(tert);
    @include bgcolor(tert);

    &:hover {
      @include fgcolor(primary, 6);
    }
  }

  head-title {
    flex: 1;
    font-weight: 500;
    @include ftsize(lg);
  }

  form-field {
    display: block;
    margin-top: 0.75rem;
  }

  form-foot {
    margin-top: 0.75rem;
    padding-top: 0.75rem;
    @include flex($center: vert, $gap: 0.5rem);
    @include border($loc: top);

    > button {
      margin-left: auto;
    }
  }

  dtpost-form {
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
</style>
