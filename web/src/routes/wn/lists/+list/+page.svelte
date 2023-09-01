<script lang="ts">
  import { goto } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  import VilistCard from '$gui/parts/review/VilistCard.svelte'
  import MdForm from '$gui/molds/MdForm.svelte'

  export let data: PageData
  let error = ''

  const [action, method] = data.lform.id
    ? [`/_db/lists/${data.lform.id}`, 'PATCH']
    : ['/_db/lists', 'POST']

  const headers = { 'content-type': 'application/json' }

  async function submit(evt: Event) {
    evt.preventDefault()
    const init = { method, headers, body: JSON.stringify(data.lform) }

    const resp = await fetch(action, init)
    const text = await resp.text()

    if (!resp.ok) {
      error = text
    } else {
      await goto(`/@${$_user.uname}/ul/${text}`)
    }
  }

  const klasses = [
    ['male', 'Nam sinh', 'Dành cho các độc giả nam'],
    ['female', 'Nữ sinh', 'Dành cho các độc giả nữ'],
    ['both', 'Tất cả', 'Dành cho tất cả hướng đối tượng'],
  ]

  const delete_list = async (_: Event) => {
    const url = `/_db/lists/${data.lform.id}`
    await fetch(url, { method: 'DELETE' })
    await goto('/wn/lists')
  }
</script>

<article class="article island">
  <h2>Thêm/sửa thư đơn truyện chữ</h2>

  <form class="form" {action} {method} on:submit={submit}>
    {#if error}<section class="error">Lỗi: {error}</section>{/if}

    <section class="ibody">
      <label class="label" for="title">Tên thư đơn</label>
      <textarea
        class="title m-input"
        name="title"
        rows="1"
        placeholder="Tên thư đơn"
        lang="vi"
        bind:value={data.lform.title}
        disabled={data.lform.id < 0} />
    </section>

    <section class="dtext">
      <label class="label" for="dtext">Giới thiệu thư đơn</label>

      <MdForm
        name="dtext"
        bind:value={data.lform.dtext}
        placeholder="Giới thiệu thư đơn"
        min_rows={6}
        disabled={$_user.privi < 0} />
    </section>

    <footer class="foot">
      <span class="klass">
        <span class="label">Hướng đối tượng:</span>

        {#each klasses as [value, label, tip]}
          <label class="radio" data-tip={tip}>
            <input type="radio" bind:group={data.lform.klass} {value} />
            {label}
          </label>
        {/each}
      </span>
      <button
        type="submit"
        class="m-btn _primary _fill"
        disabled={data.lform.title.length < 3 && data.lform.dtext.length < 1}>
        <SIcon name="send" />
        <span>{data.lform.id ? 'Lưu' : 'Tạo'} thư đơn</span>
      </button>
    </footer>
  </form>

  {#if data.lform.id > 0}
    <h3>Xoá thư đơn</h3>
    <p><em>Bạn chỉ xoá được thư đơn nếu nó không có bộ truyện nào.</em></p>

    <p>
      <button class="m-btn _harmful _fill _lg" on:click={delete_list}>
        <SIcon name="eraser" />
        <span>Xoá thư đơn</span>
      </button>
    </p>
  {/if}

  <h3>Các thư đơn khác của bạn:</h3>
  {#each data.lists as list}
    <VilistCard {list} />
  {/each}
</article>

<style lang="scss">
  .article {
    @include margin-y(var(--gutter));
  }

  .form {
    margin-top: 1rem;
    display: block;
    padding: 0 var(--gutter);

    @include border();
    @include bdradi();
  }

  section {
    margin-top: 0.5rem;
  }

  .title {
    display: block;
    width: 100%;
    @include ftsize(lg);

    padding: 0.375rem 0.75rem;
    line-height: 2rem;
    min-height: 3rem;

    font-weight: 500;
  }

  .label {
    @include fgcolor(tert);
    @include ftsize(sm);
    font-weight: 500;
    line-height: 1.75rem;
  }

  .foot {
    display: flex;
    padding: 0.75rem 0;

    button {
      margin-left: auto;
    }
  }

  .radio {
    cursor: pointer;
    @include fgcolor(main);
    margin-left: 0.25rem;
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
