<script lang="ts">
  import { goto } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import Star from '$gui/atoms/Star.svelte'
  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  import { rel_time } from '$utils/time_utils'
  import VicritCard from '$gui/parts/review/VicritCard.svelte'

  export let data: PageData

  let error = ''

  $: list_ids = data.crits.map((x) => x.list_id)

  $: if (list_ids.includes(data.cform.bl_id)) {
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
      const crit = (await res.json()) as CV.Vicrit
      await goto(`/uc/v${crit.id}`)
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

<article class="article island">
  <h2>
    Thêm/sửa đánh giá bộ truyện
    <a class="fg-link" href="/wn/{data.bslug}">{data.bname}</a>
  </h2>

  <form class="form" {action} {method} on:submit={submit}>
    <header class="head">
      <span class="cv-user" data-privi={$_user.privi}>{$_user.uname}</span>

      <span class="fg-tert">&middot;</span>
      <span class="ctime">
        {data.ctime ? rel_time(data.ctime) : 'đánh giá mới'}
      </span>

      <span class="stars">
        <span class="label show-pl">Đánh giá: </span>
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

    {#if error}<section class="error">Lỗi: {error}</section>{/if}

    <section class="ibody">
      <textarea
        class="input"
        name="input"
        rows="8"
        placeholder="Nội dung đánh giá"
        lang="vi"
        bind:value={data.cform.input} />
    </section>

    <section class="btags">
      <label class="label" for="btags">Nhãn: </label>
      <input
        type="text"
        name="btags"
        bind:value={data.cform.btags}
        placeholder="Phân cách bằng dấu phẩy (,)" />
    </section>

    <footer class="foot">
      <label class="vilist">
        <span class="label">Thư đơn:</span>
        <select
          class="m-input"
          name="vilist"
          id="vilist"
          bind:value={data.cform.bl_id}>
          {#each data.lists as list}
            <option value={list.id}>{list.title}</option>
          {/each}
        </select>
      </label>

      <button
        type="submit"
        class="m-btn _primary _fill"
        disabled={data.cform.input.length < 3}
        on:click={submit}>
        <SIcon name="send" />
        <span>{data.cform.id ? 'Lưu' : 'Tạo'} đánh giá</span>
      </button>
    </footer>
  </form>

  <h3>Các đánh giá khác cho bộ truyện</h3>

  {#each data.crits as crit}
    {@const list = data.lists.find((x) => x.id == crit.list_id)}
    <VicritCard
      {crit}
      user={$_user}
      {list}
      book={undefined}
      show_book={false} />
  {:else}
    <p class="fg-tert">Chưa có đánh giá khác.</p>
  {/each}
</article>

<style lang="scss">
  .article {
    @include margin-y(var(--gutter));

    p {
      margin-top: 0.75rem;
    }
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

  .btags {
    display: flex;
    align-items: center;
    gap: 0.5rem;

    > input {
      flex: 1;
      font-size: em(15, 16);
      padding: 0 0.5rem;
      line-height: 1.25rem;
      height: 2rem;

      background: none;
      @include bdradi();
      @include border(--bd-soft);
    }
  }

  section {
    padding: 0 var(--gutter);
    margin-top: 0.75rem;
  }

  .input {
    font-size: 1.1rem;
    min-height: 7rem;
    width: 100%;
    background: none;
    border: none;
  }

  .label {
    @include fgcolor(tert);
    @include ftsize(sm);
    font-weight: 500;
  }

  .foot {
    display: flex;
    padding: 0.75rem var(--gutter);

    button {
      margin-left: auto;
    }
  }

  .vilist {
    display: inline-flex;
    gap: 0.5rem;
    height: 2rem;
    align-items: center;
    // flex: 1;
    // line-height: 2rem;
  }

  .error {
    line-height: 1.5rem;
    margin-top: 0.25rem;
    margin-bottom: -0.5rem;
    font-style: italic;
    @include ftsize(sm);
    @include fgcolor(harmful, 5);
  }

  h3 {
    margin-top: 1rem;
  }
</style>
