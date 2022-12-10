<script lang="ts">
  import { session } from '$lib/stores'

  import Star from '$gui/atoms/Star.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let nvinfo: CV.Nvinfo
  export let form: CV.VicritForm = { id: 0, stars: 3, input: '', btags: '' }

  export let on_success = (crit: CV.Vicrit) => console.log(crit)

  let error = ''

  $: update = form.id != 0
  $: action = update ? `/api/crits/${form.id}` : '/api/crits'
  $: method = update ? 'PATCH' : 'POST'

  async function submit(evt: Event) {
    evt.preventDefault()

    const body = { ...form, book: nvinfo.id }
    const headers = { 'content-type': 'application/json' }

    // prettier-ignore
    const res = await fetch(action, {method, body: JSON.stringify(body), headers})
    if (res.ok) on_success((await res.json()) as CV.Vicrit)
    else error = await res.text()
  }
</script>

<form class="form" {action} {method} on:submit={submit}>
  <header class="head">
    <span class="cv-user" data-privi={$session.privi}>{$session.uname}</span>
    <span class="stars">
      {#each [1, 2, 3, 4, 5] as star}
        <button type="button" class="star" on:click={() => (form.stars = star)}>
          <Star active={star <= form.stars} />
        </button>
      {/each}
    </span>
  </header>

  {#if error}<section class="error">Lỗi: {error}</section>{/if}

  <section class="ibody">
    <textarea
      class="m-input"
      name="input"
      rows="8"
      placeholder="Nội dung đánh giá"
      bind:value={form.input} />
  </section>

  <section class="btags">
    <label class="label" for="btags">Nhãn: </label>
    <input
      type="text"
      name="btags"
      class="m-input _sm"
      bind:value={form.btags}
      placeholder="Phân cách bằng dấu phẩy (,)" />
  </section>

  <footer class="foot">
    <button
      type="submit"
      class="m-btn _primary _fill"
      disabled={form.input.length < 1}
      on:click={submit}>
      <SIcon name="send" />
      <span>{update ? 'Lưu' : 'Tạo'} đánh giá</span>
    </button>
  </footer>
</form>

<style lang="scss">
  .form {
    display: block;
    // padding: 0 0.75rem;

    @include border();
    @include bdradi();
  }

  .head {
    display: flex;

    padding: 0 var(--gutter);
    line-height: 2.25rem;

    @include border(--bd-soft, $loc: bottom);
  }

  .stars {
    display: inline-flex;
    margin-left: auto;
    align-items: center;
  }

  .star {
    background: none;
    > :global(svg) {
      width: 1.125rem;
    }
  }

  .btags {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    > input {
      flex: 1;
      padding-left: 0.5rem;
      padding-right: 0.5rem;
      font-size: em(15, 16);
    }
  }

  section {
    padding: 0 var(--gutter);
    margin-top: 0.75rem;
  }

  .m-input {
    display: block;
    width: 100%;
  }

  textarea {
    font-size: 1.1rem;
  }

  .label {
    @include fgcolor(tert);
    @include ftsize(sm);
    font-weight: 500;
  }

  .foot {
    display: flex;
    justify-content: right;
    padding: 0.75rem var(--gutter);
  }

  .error {
    line-height: 1.5rem;
    margin-top: 0.25rem;
    margin-bottom: -0.5rem;
    font-style: italic;
    @include ftsize(sm);
    @include fgcolor(harmful, 5);
  }
</style>
