<script lang="ts">
  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Star from '$gui/atoms/Star.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  export let nvinfo: CV.Wninfo
  export let form: CV.VicritForm = {
    id: 0,
    stars: 3,
    input: '',
    btags: '',
    bl_id: 0,
  }

  export let on_success = (crit: CV.Vicrit) => console.log(crit)

  let error = ''

  $: update = form.id != 0
  $: action = update ? `/_db/crits/${form.id}` : '/_db/crits'
  $: method = update ? 'PATCH' : 'POST'

  const headers = { 'content-type': 'application/json' }

  async function submit(evt: Event) {
    evt.preventDefault()

    const body = {
      wn_id: nvinfo.id,
      bl_id: form.bl_id,
      stars: +form.stars,
      input: form.input.trim(),
      btags: form.btags.split(',').map((x) => x.trim()),
    }

    const init = { method, headers, body: JSON.stringify(body) }
    const res = await fetch(action, init)

    if (!res.ok) {
      error = await res.text()
    } else {
      const crit = (await res.json()) as CV.Vicrit
      on_success(crit)
    }
  }
</script>

<form class="form" {action} {method} on:submit={submit}>
  <header class="head">
    <span class="cv-user" data-privi={$_user.privi}>{$_user.uname}</span>
    <span class="stars">
      {#each [1, 2, 3, 4, 5] as star}
        <button type="button" class="star" on:click={() => (form.stars = star)}>
          <Star active={star <= form.stars} />
        </button>
      {/each}

      <span class="star-out">{form.stars} sao</span>
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
      disabled={form.input.length < 3}
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
