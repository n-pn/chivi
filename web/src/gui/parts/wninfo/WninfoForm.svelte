<script context="module" lang="ts">
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
  export let wnform: CV.WnForm

  let errors: string

  async function submit(evt: Event) {
    evt.preventDefault()
    for (const key in wnform) {
      if (key == 'ztitle' || key == 'zauthor') continue
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
    wnform.vtitle = await fetch_text(href)
    console.log(wnform.vtitle)
  }

  const tl_author = async (value: string) => {
    const href = `/_m1/qtran/tl_author?author=${value}&wn_id=${nvinfo.id}`
    wnform.vauthor = await fetch_text(href)
  }

  const tl_bintro = async (body: string) => {
    const href = `/_m1/qtran?wn_id=${nvinfo.id}&format=txt`
    const headers = { 'Content-Type': 'text/plain' }
    wnform.vintro = await fetch_text(href, { method: 'POST', body, headers })
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
        <label class="form-label" for="ztitle">Tên truyện tiếng Trung</label>
        <input
          type="text"
          class="m-input"
          name="ztitle"
          placeholder="Tựa bộ truyện"
          disabled={nvinfo.id != 0}
          on:change={() => tl_btitle(wnform.ztitle)}
          required
          bind:value={wnform.ztitle} />
      </form-field>

      <form-field>
        <label class="form-label" for="vtitle">Tên truyện tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="vtitle"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={wnform.vtitle} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="zauthor">Tên tác giả tiếng Trung</label>
        <input
          type="text"
          class="m-input"
          name="zauthor"
          placeholder="Tên tác giả bộ truyện"
          required
          disabled={nvinfo.id != 0}
          on:change={() => tl_author(wnform.zauthor)}
          bind:value={wnform.zauthor} />
      </form-field>

      <form-field>
        <label class="form-label" for="vauthor">Tên tác giả tiếng Việt</label>
        <input
          type="text"
          class="m-input"
          name="vauthor"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={wnform.vauthor} />
      </form-field>
    </form-group>

    <form-group>
      <form-field>
        <label class="form-label" for="zintro">Giới thiệu tiếng Trung</label>
        <textarea
          class="m-input"
          name="zintro"
          rows="8"
          placeholder="Giới thiệu vắn tắt nội dung"
          on:change={() => tl_bintro(wnform.zintro)}
          bind:value={wnform.zintro} />
      </form-field>

      <form-field>
        <label class="form-label" for="vintro">Giới thiệu tiếng Việt</label>
        <textarea
          class="m-input"
          name="vintro"
          rows="8"
          placeholder="Để trắng để hệ thống tự gợi ý"
          bind:value={wnform.vintro} />
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
</style>
