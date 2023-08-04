<!-- <script context="module" lang="ts">
  import { bgenres } from '$lib/constants'
</script>

<script lang="ts">
  import { goto } from '$app/navigation'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import { api_call } from '$lib/api_call'

  import { book_status } from '$utils/nvinfo_utils'

  import SIcon from '$gui/atoms/SIcon.svelte'

  export let nvinfo: Partial<CV.Wninfo>
  export let wnform: CV.Wnform

  let errors: string

  async function submit(evt: Event) {
    evt.preventDefault()
    for (const key in wnform) {
      if (key == 'btitle_zh' || key == 'author_zh') continue
      const val = wnform[key]
      if (val == nvinfo[key]) delete wnform[key]
    }

    try {
      const { id, bslug } = await api_call('/_db/books', wnform, 'POST')
      await goto(`/wn/${id}-${bslug}`)
    } catch (ex) {
      errors = ex.body.message
    }
  }

  const remove_genre = (genre: string) => {
    wnform.genres = wnform.genres.filter((x) => x != genre)
  }

  const add_genre = (genre: string) => {
    wnform.genres = [...wnform.genres, genre]
  }

  let show_genres_menu = false
  let show_genres_more = false

  const tl_btitle = async (value: string) => {
    const href = `/_m1/qtran/tl_btitle?btitle=${value}&wn_id=${nvinfo.id}`
    wnform.btitle_vi = await fetch_text(href)
    console.log(wnform.btitle_vi)
  }

  const tl_author = async (value: string) => {
    const href = `/_m1/qtran/tl_author?author=${value}&wn_id=${nvinfo.id}`
    wnform.author_vi = await fetch_text(href)
  }

  const tl_bintro = async (body: string) => {
    const href = `/_m1/qtran?wn_id=${nvinfo.id}&format=txt`
    const headers = { 'Content-Type': 'text/plain' }
    wnform.intro_vi = await fetch_text(href, { method: 'POST', body, headers })
  }

  const fetch_text = async (href: string, init?: RequestInit) => {
    const res = await fetch(href, init)
    return await res.text()
  }
</script>

<article class="article">
  <header>
    <slot name="header"><h1>Thêm/sửa thông tin bộ truyện</h1></slot>
  </header>

  <form action="/_db/books" method="POST" on:submit={submit}>
    <form-group>
      <form-field>
        <label class="form-label" for="btitle_zh">Tên truyện tiếng Trung</label>
        <input
          type="text"
          class="m-input"
          name="btitle_zh"
          placeholder="Tựa bộ truyện"
          disabled={nvinfo.id != 0}
          on:change={() => tl_btitle(wnform.btitle_zh)}
          required
          bind:value={wnform.btitle_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="btitle_vi">Tên truyện tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="btitle_vi"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={wnform.btitle_vi} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="author_zh"
          >Tên tác giả tiếng Trung</label>
        <input
          type="text"
          class="m-input"
          name="author_zh"
          placeholder="Tên tác giả bộ truyện"
          required
          disabled={nvinfo.id != 0}
          on:change={() => tl_author(wnform.author_zh)}
          bind:value={wnform.author_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="author_vi">Tên tác giả tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="author_vi"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={wnform.author_vi} />
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
          on:change={() => tl_bintro(wnform.intro_zh)}
          bind:value={wnform.intro_zh} />
      </form-field>

      <form-field>
        <label class="form-label" for="intro_vi">Giới thiệu tiếng Việt</label>
        <textarea
          class="m-input"
          name="intro_vi"
          rows="8"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={wnform.intro_vi} />
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
          bind:value={wnform.bcover} />
      </form-field>
    </form-group>

    <div class="form-group genres">
      <form-field>
        <label class="label" for="genres">Thể loại</label>

        <div class="m-chips">
          {#each wnform.genres as genre}
            <button
              type="button"
              class="m-chip _success"
              on:click={() => remove_genre(genre)}>
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
              {@const included = wnform.genres.includes(vgenre)}
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
              <SIcon
                name={show_genres_more ? 'chevron-left' : 'chevron-right'} />
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
              <input
                type="radio"
                bind:group={wnform.status}
                name="status"
                {value} />
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
      <button
        class="m-btn _primary _fill _lg"
        type="submit"
        disabled={$_user.privi < 2}>
        <SIcon name="send" />
        <span class="-txt">Lưu thông tin</span>
        <SIcon name="privi-2" iset="sprite" />
      </button>
    </form-group>
  </form>
</article>

<style lang="scss">
  article {
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
</style> -->
