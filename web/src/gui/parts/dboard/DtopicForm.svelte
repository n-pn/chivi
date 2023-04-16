<script context="module" lang="ts">
  import { writable } from 'svelte/store'
  import { dtopic_form as data } from '$lib/stores'
  import { dlabels } from '$lib/constants'

  function build_labels(labels: string): Record<string, boolean> {
    const output = {}
    labels.split(',').forEach((x) => (output[x] = true))
    return output
  }

  function extract_labels(labels: Record<string, boolean>) {
    const output = []
    for (let k in labels) if (labels[k]) output.push(k)
    return output.join(',')
  }

  export const ctrl = {
    ...writable({ id: 0, actived: false }),
    show(id = 0) {
      data.init(id)
      ctrl.set({ id, actived: true })
    },
    hide() {
      ctrl.set({ id: 0, actived: false })
    },
  }
</script>

<script lang="ts">
  import SIcon from '$gui/atoms/SIcon.svelte'
  import MdForm from '$gui/molds/MdForm.svelte'
  import Dialog from '$gui/molds/Dialog.svelte'

  export let dboard: CV.Dboard
  $: dboard = dboard || { id: -1, bname: 'Đại sảnh', bslug: 'dai-sanh' }

  export let on_destroy = () => window.location.reload()

  $: on_edit = $ctrl.id != 0
  $: action = api_endpoint(dboard.id, $ctrl.id)

  let labels = build_labels($data.labels)
  $: $data.labels = extract_labels(labels)

  let error = ''

  function api_endpoint(b_id: number, t_id?: number) {
    return t_id ? `/_db/topics/${t_id}` : `/_db/topics?b_id=${b_id}`
  }

  async function submit() {
    error = await data.submit(action)
    if (error) return

    data.init()
    ctrl.hide()

    on_destroy()
  }

  const focus = (node: HTMLElement) => node.focus()
</script>

<Dialog actived={$ctrl.actived} class="cvpost" on_close={ctrl.hide}>
  <svelte:fragment slot="header">
    <head-board>{dboard.bname}</head-board>
    <head-sep>
      <SIcon name="caret-right" />
    </head-sep>
    <head-title>
      {#if on_edit}Sửa chủ đề{:else}Tạo chủ đề mới{/if}
    </head-title>
  </svelte:fragment>

  <board-form>
    <form {action} method="POST" on:submit|preventDefault={submit}>
      <form-field>
        <form-chips>
          <label-cap>Phân loại:</label-cap>
          {#each Object.entries(dlabels) as [value, klass]}
            <label class="m-label _{klass}">
              <input type="checkbox" {value} bind:checked={labels[value]} />
              <label-name>{value}</label-name>
              {#if labels[value]}<SIcon name="check" />{/if}
            </label>
          {/each}
        </form-chips>
      </form-field>

      <form-field class="title">
        <textarea
          class="m-input"
          name="title"
          lang="vi"
          bind:value={$data.title}
          use:focus
          placeholder="Chủ đề thảo luận" />
      </form-field>

      <form-field class="body">
        <MdForm
          bind:value={$data.btext}
          name="btext"
          placeholder="Nội dung thảo luận" />
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
          <span>{#if on_edit}Lưu nội dung{:else}Tạo chủ đề{/if}</span>
        </button>
      </form-foot>
    </form>
  </board-form>
</Dialog>

<style lang="scss">
  board-form {
    display: block;
    width: 40rem;
    max-width: 100%;
    padding: 0 0.75rem;
  }

  head-sep {
    @include flex-ca;
  }

  form-field {
    display: block;
    margin-top: 0.75rem;
  }

  label-cap {
    font-weight: 500;
    @include fgcolor(secd);
  }

  form-foot {
    padding: 0.75rem 0;
    // padding-top: 0.75rem;
    @include flex($center: vert, $gap: 0.5rem);
    // @include border($loc: top);

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
      padding: 0.25rem 0.75rem;
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
