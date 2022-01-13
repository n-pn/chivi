<script context="module">
  import { invalidate } from '$app/navigation'
  import { dlabels } from '$lib/constants'
</script>

<script>
  import SIcon from '$atoms/SIcon.svelte'

  export let dboard = {
    id: 0,
    bname: 'Thảo luận',
  }

  export let form = {
    id: 0,
    title: '',
    labels: [1],
    body_input: '',
    body_itype: 'md',
  }

  let error = ''
  $: mode = form.id > 0 ? 'update' : 'create'

  $: api_url =
    `/api/boards/${dboard.id}/` + (mode == 'create' ? 'new' : 'edit/' + form.id)

  async function submit() {
    if (is_invalid_form(form)) return

    const res = await fetch(api_url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(params),
    })

    if (res.ok) console.log(await res.json())
    else error = await res.text()

    invalidate(`/api/boards/${nvinfo.id}/topics`)
  }

  function is_invalid_form(form) {
    if (form.title.length < 5 || form.title.length > 200) return true
    // TODO
    return false
  }
</script>

<board-form>
  <form action={api_url} method="POST" on:submit|preventDefault={submit}>
    <form-field>
      <label class="form-label" for="title">Chủ đề mới</label>
      <textarea
        class="m-input"
        name="title"
        lang="vi"
        bind:value={form.title} />
    </form-field>

    {#if error}
      <form-error>{error}</form-error>
    {/if}

    <form-foot>
      <form-labels>
        <label-caption>Nhãn:</label-caption>

        {#each Object.entries(dlabels) as [value, label]}
          <label
            class="topic-label _{value}"
            class:_active={form.labels.includes(value)}
            ><input type="checkbox" {value} bind:group={form.labels} />
            <label-name>{label}</label-name>
            {#if form.labels.includes(value)}
              <SIcon name="check" />
            {/if}
          </label>
        {/each}
      </form-labels>

      <button
        type="submit"
        class="m-btn _primary _fill"
        disabled={is_invalid_form(form)}
        on:click|preventDefault={submit}>
        <span>Tạo chủ đề</span>
      </button>
    </form-foot>
  </form>
</board-form>

<style lang="scss">
  form-field {
    display: block;
  }

  .form-label {
    display: block;
    line-height: 1.75rem;
    font-weight: 500;
    margin-top: 0.25rem;
    @include fgcolor(secd);
  }

  form-foot {
    @include flex($center: vert, $gap: 0.5rem);
    margin-top: 0.75rem;
  }

  textarea {
    display: block;
    width: 100%;
    min-height: 5.5rem;
    max-height: 10rem;
    font-weight: 500;

    @include ftsize(lg);
    @include fgcolor(secd);
  }

  board-form {
    display: block;
    margin-top: 0.25rem;
  }

  form-labels {
    @include flex($gap: 0.25rem);
    flex: 1;
    flex-wrap: wrap;
    @include ftsize(sm);
  }

  label-caption {
    font-weight: 500;
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

  .topic-label > input {
    display: none;
  }
</style>
