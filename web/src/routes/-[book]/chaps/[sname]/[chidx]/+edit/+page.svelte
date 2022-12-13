<script lang="ts">
  import { goto } from '$app/navigation'
  import { page } from '$app/stores'

  import { session } from '$lib/stores'
  import { uncache } from '$lib/api_call'

  import { hash_str } from '$utils/text_utils'

  import { SIcon, Footer } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, sname } = $page.data)

  let chidx = data.chidx
  let chvol = data.chvol
  let title = data.title
  let input = data.input

  let form = {
    tosimp: false,
    unwrap: false,
    split_mode: 0,
  }

  $: privi = $session.privi || -1
  $: disabled = (privi == 1 && input.length > 30000) || privi < 1
  $: action_url = `/api/texts/${nvinfo.id}/${sname}`

  async function submit() {
    const body = new FormData()

    body.append('text', input)
    body.append('hash', hash_str(input))

    body.append('title', title)
    body.append('chvol', chvol)
    body.append('chidx', chidx.toString())
    body.append('split_mode', '0')
    body.append('min_repeat', '9')

    for (const key in form) body.append(key, form[key].toString())
    const res = await fetch(action_url, { method: 'PUT', body })

    if (res.ok) {
      await res.json()
      uncache('nslists', nvinfo.id)
      uncache('nvseeds', `${nvinfo.id}/${sname}`)
      goto(`/-${nvinfo.bslug}/chaps/${sname}/${chidx}`)
    } else {
      alert(await res.text())
    }
  }
</script>

<svelte:head>
  <title>Sửa text gốc chương #{chidx} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<nav class="bread">
  <a href="/-{nvinfo.bslug}" class="crumb _link">
    <SIcon name="book" />
    <span>{nvinfo.btitle_vi}</span>
  </a>
  <span>/</span>
  <a href="/-{nvinfo.bslug}/-union" class="crumb _link">Chương tiết</a>
</nav>

<section class="article">
  <h2>Sửa text chương #{chidx}</h2>

  <form action={action_url} method="POST" on:submit|preventDefault={submit}>
    <div class="form-group _fluid">
      <span class="form-field">
        <label class="label" for="chvol">Tên tập truyện</label>
        <input
          class="m-input"
          name="chvol"
          lang="zh"
          bind:value={chvol}
          placeholder="Có thể để trắng" />
      </span>

      <span class="form-field">
        <label class="label" for="title">Tên chương tiết</label>
        <input class="m-input" name="title" lang="zh" bind:value={title} />
      </span>
    </div>

    <div class="form-field">
      <label class="label" for="input">Nội dung chương</label>
      <textarea class="m-input" name="input" lang="zh" bind:value={input} />
    </div>

    <div class="form-field">
      <div class="label">Lựa chọn nâng cao</div>
      <div class="options">
        <label class="label">
          <input type="checkbox" name="tosimp" bind:checked={form.tosimp} />
          <span>Chuyển từ Phồn -> Giản</span>
        </label>

        <label class="label">
          <input type="checkbox" name="unwrap" bind:checked={form.unwrap} />
          <span>Sửa lỗi vỡ dòng</span>
        </label>
      </div>
    </div>

    <Footer>
      <div class="pagi">
        <label class="label" for="chidx">
          <span>Đánh số chương</span>
          <input class="m-input" name="chidx" bind:value={chidx} />
        </label>

        <button type="submit" class="m-btn _primary _fill" {disabled}>
          <SIcon name="upload" />
          <span class="-text">Đăng tải</span>
          <SIcon name="privi-1" iset="sprite" />
        </button>
      </div>
    </Footer>
  </form>
</section>

<style lang="scss">
  textarea {
    display: block;
    width: 100%;
    min-height: 10rem;
    height: calc(100vh - 25rem);
    padding: 0.75rem;
    font-size: rem(18px);
    margin-bottom: 0.5rem;
  }

  h2 {
    padding: 0.75rem 0;
  }

  section {
    padding-bottom: 0.5rem;
  }

  .pagi {
    @include flex-cy($gap: 0.5rem);

    .m-input {
      display: inline-block;
      &[name='chidx'] {
        margin-left: 0.25rem;
        width: 3.5rem;
        text-align: center;
        padding: 0 0.25rem;
      }
    }

    .label {
      @include bgcolor(tert);
      height: 100%;
      // height: 2rem;
    }

    .m-btn {
      margin-left: auto;
    }
  }

  .label {
    display: block;
    // text-transform: uppercase;
    font-weight: 500;
    @include ftsize(sm);
    @include fgcolor(tert);
    // margin-bottom: 0.25rem;
  }

  .form-group {
    display: flex;
    gap: 0.75rem;

    flex-direction: column;

    > .form-field {
      width: 100%;
    }

    @include bp-min(ts) {
      flex-direction: row;
    }

    > .form-field {
      display: flex;
      gap: 0.5rem;
      position: relative;
      align-items: center;

      @include bp-min(ts) {
        &:first-child {
          width: 40%;
        }

        &:last-child {
          width: 60%;
        }
      }
    }

    label {
      position: absolute;
      bottom: 100%;
      left: 0;
    }

    input {
      width: 100%;
    }
  }

  .options {
    display: flex;
    flex-wrap: wrap;
    gap: 0.5rem;
    align-items: center;
    padding: 0.25rem 0;

    label {
      @include fgcolor(secd);
    }
  }
</style>
