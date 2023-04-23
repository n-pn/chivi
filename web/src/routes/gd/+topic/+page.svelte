<script context="module" lang="ts">
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
</script>

<script lang="ts">
  import { goto } from '$app/navigation'
  import { api_call } from '$lib/api_call'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import MdForm from '$gui/molds/MdForm.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let labels = build_labels(data.dtform.labels || '')
  let error = ''

  const on_edit = data.dtform.id != 0
  const [action, method] = on_edit
    ? [`/_db/topics/${data.dtform.id}`, 'PATCH']
    : [`/_db/topics?b_id=${data.dboard.id}`, 'POST']

  const validate = ({ title, btext }: CV.DtopicForm) => {
    if (title.length > 200) return 'Độ dài của chủ đề phải nhỏ hơn 200 ký tự'

    if (title.length < 4) return 'Độ dài của chủ đề phải dài hơn 3 ký tự'
    if (btext.length < 4) return 'Độ dài của nội dung phải dài hơn 3 ký tự'

    return ''
  }

  async function submit(evt: Event) {
    evt.preventDefault()

    data.dtform.labels = extract_labels(labels)

    error = validate(data.dtform)
    if (error) return

    try {
      const { id, tslug } = await api_call(action, data.dtform, method)
      await goto(`/gd/t-${id}-${tslug}`)
    } catch (ex) {
      error = ex.body?.message || ex.message
    }
  }

  const focus = (node: HTMLElement) => node.focus()
</script>

<header class="head">
  <head-board>{data.dboard.bname}</head-board>
  <SIcon name="caret-right" />

  <span>{on_edit ? 'Sửa chủ đề' : 'Tạo chủ đề mới'}</span>
</header>

<form class="form" {action} {method} on:submit={submit}>
  <section class="chips">
    <label-cap>Phân loại:</label-cap>
    {#each Object.entries(dlabels) as [value, klass]}
      <label class="m-label _{klass}">
        <input type="checkbox" {value} bind:checked={labels[value]} />
        <label-name>{value}</label-name>
        {#if labels[value]}<SIcon name="check" />{/if}
      </label>
    {/each}
  </section>

  <form-field class="title">
    <label class="label" for="btext">Chủ đề thảo luận:</label>

    <textarea
      class="m-input"
      name="title"
      lang="vi"
      bind:value={data.dtform.title}
      use:focus
      placeholder="Chủ đề thảo luận" />
  </form-field>

  <form-field class="body">
    <label class="label" for="btext">Nội dung thảo luận:</label>
    <MdForm
      bind:value={data.dtform.btext}
      name="btext"
      placeholder="Nội dung thảo luận"
      min_rows={10} />
  </form-field>

  {#if error}
    <form-error>{error}</form-error>
  {/if}

  <form-foot>
    <button type="submit" class="m-btn _primary _fill" on:click>
      <SIcon name="send" />
      <!-- prettier-ignore -->
      <span>{#if on_edit}Lưu nội dung{:else}Tạo chủ đề{/if}</span>
    </button>
  </form-foot>
</form>

<style lang="scss">
  .label {
    @include fgcolor(tert);
    @include ftsize(sm);
    font-weight: 500;
    line-height: 1.75rem;
  }

  .head {
    @include flex-cy;

    height: 2.25rem;
    line-height: 2.25rem;
    font-weight: 500;
    @include border(--bd-main, $loc: bottom);
    @include fgcolor(secd);
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

  .chips {
    margin-top: 0.75rem;
    @include flex-cy($gap: 0.5rem);

    flex-wrap: wrap;
    @include ftsize(sm);
  }

  .m-label {
    height: 1.75rem;
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
