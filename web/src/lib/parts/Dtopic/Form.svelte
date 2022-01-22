<script context="module">
  import { writable } from 'svelte/store'
  import { dlabels } from '$lib/constants'

  function build_labels(labels) {
    const output = {}
    labels.forEach((x) => (output[x] = true))
    return output
  }

  function extract_labels(labels) {
    const output = []
    for (let k in labels) if (labels[k]) output.push(+k)
    return output
  }

  async function load_dtopic(id) {
    if (id == 0) return init_dtopic(id)

    const api_url = `/api/topics/${id}/detail`
    const api_res = await fetch(api_url)

    if (api_res.ok) return await api_res.json()
    else return init_dtopic()
  }

  function init_dtopic() {
    return {
      title: '',
      labels: [1],
      body_input: '',
      body_itype: 'md',
    }
  }

  const form = {
    ...writable(init_dtopic()),
    init: async (id = 0) => form.set(await load_dtopic(id)),
  }

  export const ctrl = {
    ...writable({ id: 0, actived: false }),
    show(id = 0) {
      form.init(id)
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

  export let dboard = { id: 0, bname: 'Thảo luận' }
  export let on_destroy = () => window.location.reload()

  $: on_edit = $ctrl.id > 0
  $: api_url = make_api_endpoint(dboard.id, on_edit)

  let labels = build_labels($form.labels)
  $: $form.labels = extract_labels(labels)

  let error = ''

  function make_api_endpoint(dboard_id, on_edit) {
    let api_url = '/api/topics'
    if (on_edit) api_url += '/' + $ctrl.id
    return api_url + '?dboard=' + dboard_id
  }

  async function submit() {
    if (is_invalid_form($form)) return

    console.log({ api_url })
    const res = await fetch(api_url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify($form),
    })

    if (res.ok) {
      ctrl.hide()
      on_destroy()
    } else {
      error = await res.text()
    }
  }

  function is_invalid_form(form) {
    if (form.title.length < 4 || form.title.length > 200) return true
    if (form.body_input.length < 1 || form.body_input.length > 2000) return true
    // TODO
    return false
  }
</script>

<Gmodal actived={$ctrl.actived} on_close={ctrl.hide}>
  <board-form>
    <board-head>
      <head-title>
        {#if on_edit}Sửa chủ đề{:else}Tạo chủ đề mới{/if}
      </head-title>

      <button type="button" data-kbd="esc" class="x-btn" on:click={ctrl.hide}>
        <SIcon name="x" />
      </button>
    </board-head>

    <form action={api_url} method="POST" on:submit|preventDefault={submit}>
      <form-field class="title">
        <input
          class="m-input"
          name="title"
          lang="vi"
          bind:value={$form.title}
          placeholder="Chủ đề thảo luận" />
      </form-field>

      <form-field class="body">
        <MdForm
          bind:value={$form.body_input}
          name="body_input"
          placeholder="Nội dung thảo luận" />
      </form-field>

      {#if error}
        <form-error>{error}</form-error>
      {/if}

      <form-field>
        <form-label>Phân loại chủ đề:</form-label>

        <form-chips>
          {#each Object.entries(dlabels) as [value, label]}
            <label class="m-label _{value}">
              <input type="checkbox" {value} bind:checked={labels[value]} />
              <label-name>{label}</label-name>
              {#if labels[value]}
                <SIcon name="check" />
              {/if}
            </label>
          {/each}
        </form-chips>
      </form-field>

      <form-foot>
        <button
          type="submit"
          class="m-btn _primary _fill"
          disabled={is_invalid_form($form)}
          on:click|preventDefault={submit}>
          <SIcon name="send" />
          <!-- prettier-ignore -->
          <span>{#if on_edit}Lưu nội dung{:else}Tạo chủ đề{/if}</span>
        </button>
      </form-foot>
    </form>
  </board-form>
</Gmodal>

<style lang="scss">
  board-form {
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

  board-head {
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

  form-label {
    display: block;
    line-height: 1.75rem;
    font-weight: 500;
    margin-top: 0.25rem;
    @include fgcolor(secd);
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

  .m-input {
    display: block;
    width: 100%;
    @include fgcolor(secd);

    &[name='title'] {
      @include ftsize(lg);
      font-weight: 500;
      padding-top: 0.75rem;
      padding-bottom: 0.75rem;
    }
  }

  board-form {
    display: block;
    margin-top: 0.25rem;
  }

  form-chips {
    @include flex($gap: 0.25rem);
    flex: 1;
    flex-wrap: wrap;
    @include ftsize(sm);
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

  .m-label > input {
    display: none;
  }
</style>
