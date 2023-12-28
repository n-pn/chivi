<script lang="ts">
  import { goto } from '$app/navigation'
  import { api_call } from '$lib/api_call'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import SIcon from '$gui/atoms/SIcon.svelte'

  import type { PageData } from './$types'
  export let data: PageData

  let uform = data.uform
  let labels = (uform.labels || []).join(', ')

  let err_text: string
  let confirm: number

  $: action = uform.id ? `/_rd/upstems/${uform.id}` : '/_rd/upstems'

  const tl_btitle = async () => {
    uform.vname = await qt_hviet(uform.zname)
  }

  const tl_author = async () => {
    uform.au_vi = await qt_hviet(uform.au_zh)
  }

  const qt_hviet = async (ztext: string) => {
    const res = await fetch(`/_sp/hname?input=${ztext}`)
    return await res.text()
  }

  const tl_intro = async () => {
    const url = `/_m1/qtran?format=txt`
    const res = await fetch(url, { method: 'POST', body: uform.zdesc })
    uform.vdesc = await res.text()
  }

  const submit = async () => {
    const body = { ...uform, labels: labels.split(',') }

    try {
      const { ustem } = await api_call(action, body, 'POST')
      await goto(`/up/${ustem.sname}:${ustem.id}`)
    } catch (ex) {
      err_text = ex.body.message
    }
  }

  const delete_project = async () => {
    const res = await fetch(`/_rd/upstems/${uform.id}`, { method: 'DELETE' })

    if (res.ok) goto('/up')
    else err_text = await res.text()
  }
</script>

<form {action} method="POST" on:submit|preventDefault={submit}>
  <form-group>
    <form-field>
      <label class="form-label" for="zname">Tên sưu tầm (Trung)</label>
      <input
        type="text"
        class="m-input"
        name="zname"
        placeholder="Tên gốc tiếng Trung"
        required
        on:change={tl_btitle}
        bind:value={uform.zname} />
    </form-field>

    <form-field>
      <label class="form-label" for="vname">Tên sưu tầm (Việt)</label>
      <input
        type="text"
        name="vname"
        class="m-input"
        placeholder="Để trắng để hệ thống tự gợi ý"
        bind:value={uform.vname} />
    </form-field>
  </form-group>

  <form-group>
    <form-field>
      <label class="form-label" for="au_zh">Tên tác giả (Trung)</label>
      <input
        type="text"
        name="au_zh"
        class="m-input"
        required
        placeholder="Tên tác giả Tiếng Trung"
        on:change={tl_author}
        bind:value={uform.au_zh} />
    </form-field>

    <form-field>
      <label class="form-label" for="au_vi">Tên tác giả (Việt)</label>
      <input
        type="text"
        name="au_vi"
        class="m-input"
        placeholder="Để trắng để hệ thống tự gợi ý"
        bind:value={uform.au_vi} />
    </form-field>
  </form-group>

  <form-group>
    <form-field>
      <label class="form-label" for="zdesc">Giới thiệu (Trung)</label>
      <textarea
        name="zdesc"
        class="m-input"
        rows="8"
        placeholder="Giới thiệu tiếng Trung"
        on:change={tl_intro}
        bind:value={uform.zdesc} />
    </form-field>

    <form-field>
      <label class="form-label" for="vdesc">Giới thiệu (Việt)</label>
      <textarea
        name="vdesc"
        class="m-input"
        rows="8"
        placeholder="Giới thiệu tiếng Việt"
        bind:value={uform.vdesc} />
    </form-field>
  </form-group>

  <div class="form-group">
    <label class="form-label" for="img_og">Đường dẫn ảnh bìa</label>
    <input
      type="url"
      name="img_og"
      class="m-input"
      placeholder="https://..."
      bind:value={uform.img_og} />
  </div>

  <div class="form-group labels">
    <label class="form-label" for="labels">Nhãn tìm kiếm</label>
    <input
      type="text"
      class="m-input"
      name="labels"
      placeholder="Tách các nhãn bằng dấu phẩy. Các nhãn bằng tiếng Trung sẽ được tự đổi sang tiếng Việt"
      bind:value={labels} />
  </div>

  <div class="form-group linked">
    <label class="i-label" for="wn_id">ID bộ truyện chữ:</label>
    <input
      type="number"
      name="wn_id"
      class="m-input _sm _inline"
      placeholder="ID bộ truyện"
      bind:value={uform.wn_id} />

    <label class="i-label">
      <input type="checkbox" name="wndic" bind:checked={uform.wndic} />
      <span>Dùng từ điển bộ truyện</span>
    </label>
  </div>

  {#if err_text}<div class="form-msg _err">{err_text}</div>{/if}

  <footer class="action">
    {#if uform.id}
      <div class="delete">
        <span class="label">Xóa dự án:</span>
        <input
          type="number"
          class="m-input"
          placeholder="ID dự án"
          bind:value={confirm} />
        <button
          type="button"
          class="m-btn _harmful _fill"
          disabled={confirm != uform.id}
          on:click={delete_project}>
          <SIcon name="trash" />
          <span class="-txt">Xóa</span>
        </button>
      </div>
    {/if}

    <button
      class="m-btn _primary _fill u-right"
      type="submit"
      disabled={$_user.privi < 1}>
      <SIcon name="send" />
      <span class="-txt">Đăng tải</span>
      <SIcon name="privi-1" iset="icons" />
    </button>
  </footer>
</form>

<style lang="scss">
  .m-input {
    display: block;
    width: 100%;
  }

  .form-group {
    margin-top: 0.75rem;
  }

  .linked {
    @include flex-cy($gap: 0.75rem);
    @include border($loc: top);
    padding-top: 0.75rem;

    .i-label {
      font-weight: 500;
    }

    .m-input {
      display: inline;
      width: 5rem;
      text-align: center;
    }
  }

  // .vintro {
  //   margin-top: 1rem;

  //   .form-label {
  //     display: flex;
  //   }

  //   button {
  //     margin-left: auto;
  //     background: none;
  //     @include fgcolor(tert);
  //     font-style: italic;
  //   }
  // }

  .hints {
    font-style: italic;
    @include ftsize(sm);
    @include fgcolor(tert);
    line-height: 1rem;
    margin-top: 0.5rem;
  }

  .action {
    @include flex-cy();
    @include border($loc: top);
    margin-top: 0.75rem;
    padding-top: var(--gutter);
  }

  .delete {
    @include flex-ca();
    gap: 0.5rem;
    input {
      width: 7rem;
    }
  }
</style>
