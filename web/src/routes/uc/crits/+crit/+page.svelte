<script lang="ts">
  import { goto } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Star from '$gui/atoms/Star.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'

  import type { PageData } from './$types'
  import { rel_time } from '$utils/time_utils'

  export let data: PageData
  let error = ''

  $: ({ ctime, lists, crits, bname } = data)

  $: vl_ids = crits.map((x) => x.vl_id)

  $: if (vl_ids.includes(data.cform.vl_id)) {
    error = 'Thư đơn bạn chọn đã có đánh giá, mời chọn cái khác!'
  }

  const [action, method] = data.cform.id
    ? [`/_db/crits/${data.cform.id}`, 'PATCH']
    : ['/_db/crits', 'POST']

  async function submit(evt: Event) {
    evt.preventDefault()

    const headers = { 'content-type': 'application/json' }
    const init = { method, headers, body: JSON.stringify(data.cform) }
    const res = await fetch(action, init)

    if (!res.ok) {
      error = await res.text()
    } else {
      const data = await res.json()
      console.log(data)
      await goto(`/uc/crits/v${data.vc_id}`)
    }
  }

  const scores = [
    '-/-',
    'Rất tệ (0/10)',
    'Hơi chán (2.5/10)',
    'Bình thường (5/10)',
    'Rất khá (7.5/10)',
    'Tuyệt vời (10/10)',
  ]
</script>

<h3 id="cform">
  {data._meta.title} của bạn cho bộ truyện <strong>{bname}</strong>
</h3>

<form class="form" {action} {method} on:submit={submit}>
  <header class="head">
    <span class="cv-user" data-privi={$_user.privi}>{$_user.uname}</span>

    <span class="u-fg-tert">&middot;</span>
    <span class="ctime">
      {ctime ? rel_time(ctime) : 'đánh giá mới'}
    </span>

    <span class="stars">
      <span class="m-label u-show-pl">Đánh giá: </span>
      {#each [1, 2, 3, 4, 5] as star}
        <button
          type="button"
          class="star"
          data-tip={scores[star]}
          on:click={() => (data.cform.stars = star)}>
          <Star active={star <= data.cform.stars} />
        </button>
      {/each}
    </span>
  </header>

  <section class="ibody">
    <textarea
      class="input"
      name="input"
      rows="8"
      placeholder="Nội dung đánh giá"
      lang="vi"
      bind:value={data.cform.input} />
  </section>

  <section class="m-flex _cy">
    <label class="m-label" for="btags">Hashtag:</label>
    <input
      type="text"
      name="btags"
      class="m-input _sm"
      bind:value={data.cform.btags}
      placeholder="Phân cách bằng dấu phẩy (,)" />
  </section>

  <section class="m-flex _cy">
    <label class="m-label">Thư đơn:</label>
    <select class="m-input _sm" name="vilist" id="vilist" bind:value={data.cform.vl_id}>
      {#each lists as list}
        <option value={list.vl_id}>{list.title}</option>
      {/each}
    </select>
  </section>

  {#if error}
    <section class="form-msg _err">Lỗi: {error}</section>
  {/if}

  <footer class="foot">
    <button
      type="submit"
      class="m-btn _primary _fill"
      disabled={data.cform.input.length < 3}
      on:click={submit}>
      <SIcon name="send" />
      <span class="show-ts">{data.cform.id ? 'Lưu' : 'Tạo'} đánh giá</span>
    </button>
  </footer>
</form>

<h3>Các đánh giá khác của bạn cho bộ truyện:</h3>

{#each crits as crit}
  <VicritCard {crit} book={undefined} show_book={false} />
{:else}
  <p class="u-fg-tert"><em>Chưa có đánh giá khác.</em></p>
{/each}

<style lang="scss">
  h3,
  p {
    margin: 0.75rem 0;
  }

  .form {
    margin-top: 1rem;
    display: block;
    // padding: 0 0.75rem;

    @include border();
    @include bdradi();
  }

  .head {
    display: flex;

    gap: 0.25rem;
    padding: 0 var(--gutter);
    line-height: 2.25rem;

    @include border(--bd-soft, $loc: bottom);
  }

  .ctime {
    @include ftsize(sm);
    @include fgcolor(tert);
  }

  .stars {
    display: inline-flex;

    margin-left: auto;
    align-items: center;

    :global(svg) {
      width: 1.125rem;
    }

    span {
      margin-right: 0.25rem;
    }

    button {
      background: none;
      margin-top: -0.125rem;
      padding: 0 0.125rem;
    }
  }

  section {
    padding: 0 var(--gutter);
    margin-top: 0.75rem;
    gap: 0.75rem;
  }
  .form-msg {
    margin-top: 0.25rem;
  }

  select,
  input {
    flex: 1;
    width: calc(100% - 4rem);
  }

  .input {
    display: block;
    width: 100%;
    min-height: 7rem;
    font-size: 1.1rem;
    background: none;
    border: none;
    @include border($loc: bottom);
    @include fgcolor(main);

    &:focus {
      border-color: #{color(primary, 5)};
    }
  }

  .m-input {
    padding: 0 0.5rem;
  }

  .foot {
    display: flex;
    padding: 0.75rem var(--gutter);

    button {
      margin-left: auto;
    }
  }
</style>
