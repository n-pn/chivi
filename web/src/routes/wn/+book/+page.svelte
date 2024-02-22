<script lang="ts">
  import { titleize } from '$utils/text_utils'

  import { bgenres } from '$lib/constants'
  import { goto } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { api_call } from '$lib/api_call'
  import { book_status } from '$utils/nvinfo_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let form = { ...data.form }

  let errors: string

  const action = '/_db/books'

  async function submit(evt: Event) {
    evt.preventDefault()

    try {
      if (!form.btitle_vi) await tl_btitle()
      if (!form.author_vi) await tl_author()
      if (form.intro_zh && !form.intro_vi) await tl_bintro()

      const data = await api_call(action, form, 'POST')
      await goto(`/wn/${data.id}`)
    } catch (ex) {
      errors = ex.body?.message || ex
    }
  }

  const remove_genre = (genre: string) => {
    form.genres = form.genres.filter((x) => x != genre)
  }

  const add_genre = (genre: string) => {
    form.genres = [...form.genres, genre]
  }

  let show_genres_menu = false
  let show_genres_more = false

  let au_qt = 'hname'
  let bt_qt = 'mtl_2'
  let in_qt = 'mtl_2'

  const tl_btitle = async () => {
    const href = `/_sp/qtran/${bt_qt}?zh=${form.btitle_zh}&pd=wn${data.id}`
    const text = await fetch_text(href)
    form.btitle_vi = titleize(text.trim())
  }

  const tl_author = async () => {
    const href = `/_sp/qtran/${au_qt}?zh=${form.author_zh}&pd=wn${data.id}`
    const text = await fetch_text(href)
    form.author_vi = titleize(text.trim())
  }

  const tl_bintro = async () => {
    const href = `/_sp/qtran/${in_qt}?op=txt&hs=0&ls=1&pd=wn${data.id}`
    const headers = { 'Content-Type': 'text/plain' }
    form.intro_vi = await fetch_text(href, { method: 'POST', body: form.intro_zh, headers })
  }

  const fetch_text = async (href: string, init?: RequestInit) => {
    const res = await fetch(href, init)
    return await res.text()
  }
</script>

<article class="article island">
  <header>
    <h2>Thêm/sửa thông tin bộ truyện</h2>
  </header>

  <form {action} method="POST" on:submit={submit}>
    <form-group>
      <form-field>
        <label class="form-label" for="btitle_zh">Tên truyện tiếng Trung</label>
        <input
          type="text"
          class="m-input"
          name="btitle_zh"
          placeholder="Tựa bộ truyện"
          disabled={data.id != 0}
          on:change={tl_btitle}
          required
          bind:value={form.btitle_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="btitle_vi">Tên truyện tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="btitle_vi"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={form.btitle_vi} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="author_zh">Tên tác giả tiếng Trung</label>
        <input
          type="text"
          class="m-input"
          name="author_zh"
          placeholder="Tên tác giả bộ truyện"
          required
          disabled={data.id != 0}
          on:change={tl_author}
          bind:value={form.author_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="author_vi">Tên tác giả tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="author_vi"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={form.author_vi} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="intro_zh">Giới thiệu tiếng Trung</label>
        <textarea
          class="m-input"
          name="intro_zh"
          rows="8"
          placeholder="Giới thiệu vắn tắt nội dung"
          on:change={tl_bintro}
          bind:value={form.intro_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="intro_vi">Giới thiệu tiếng Việt</label>
        <textarea
          class="m-input"
          name="intro_vi"
          rows="8"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={form.intro_vi} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="bcover">Ảnh bìa</label>
        <input
          type="text"
          class="m-input"
          name="bcover"
          placeholder="Đường dẫn tới file ảnh"
          bind:value={form.bcover} />
      </form-field>
    </form-group>

    <div class="form-group genres">
      <form-field>
        <label class="label" for="genres">Thể loại</label>

        <div class="m-chips">
          {#each form.genres as genre}
            <button type="button" class="m-chip _success" on:click={() => remove_genre(genre)}>
              <span>{genre}</span>
              <SIcon name="x" />
            </button>
          {/each}

          <button
            type="button"
            class="m-chip"
            on:click={() => (show_genres_menu = !show_genres_menu)}>
            <SIcon name={show_genres_menu ? 'minus' : 'plus'} />
          </button>
        </div>

        {#if show_genres_menu}
          <div class="m-chips suggest">
            {#each bgenres as [vgenre, _slug, primary_genre]}
              {@const included = form.genres.includes(vgenre)}
              {@const revealed = show_genres_more || primary_genre}
              <button
                type="button"
                class="m-chip _xs"
                hidden={included || !revealed}
                on:click={() => add_genre(vgenre)}>
                <span>{vgenre}</span>
                <SIcon name="plus" />
              </button>
            {/each}

            <button
              type="button"
              class="m-chip _xs"
              on:click={() => (show_genres_more = !show_genres_more)}>
              <SIcon name={show_genres_more ? 'chevron-left' : 'chevron-right'} />
            </button>
          </div>
        {/if}
      </form-field>
    </div>

    <div class="form-group">
      <form-field>
        <label class="label" for="status">Trạng thái truyện</label>

        <form-radio>
          {#each book_status as label, value}
            <label class="radio">
              <input type="radio" bind:group={form.status} name="status" {value} />
              <span>{label}</span>
            </label>
          {/each}
        </form-radio>
      </form-field>
    </div>

    {#if errors}
      <div class="form-message _err">{errors}</div>
    {/if}

    <form-group class="action">
      <button class="m-btn _primary _fill _lg" type="submit" disabled={$_user.privi < 1}>
        <SIcon name="send" />
        <span class="-txt">Lưu thông tin</span>
        <SIcon name="privi-1" iset="icons" />
      </button>
    </form-group>
  </form>
</article>

<style lang="scss">
  article {
    margin-top: var(--gutter);

    @include bp-min(tl) {
      @include padding-x(2rem);
    }
  }

  header {
    @include border($loc: bottom);
    padding-bottom: var(--gutter-small);
    margin-bottom: var(--gutter);
  }

  .label {
    display: block;
    font-weight: 500;
    margin-bottom: 0.5rem;
  }

  form-radio {
    display: block;
  }

  .radio {
    display: inline-block;
    margin-right: 0.5rem;
  }

  .m-input {
    display: block;
    width: 100%;
  }

  .suggest {
    margin-top: 0.75rem;
    margin-right: -0.25rem;
    margin-bottom: -0.25rem;

    > * {
      margin-right: 0.25rem;
      margin-bottom: 0.25rem;
    }
  }

  .form-group {
    margin-top: 0.75rem;
  }
</style>
