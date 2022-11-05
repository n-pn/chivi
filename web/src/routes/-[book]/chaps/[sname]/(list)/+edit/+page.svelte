<script lang="ts">
  // import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  import { api_call, uncache } from '$lib/api'
  import { SIcon } from '$gui'

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ nvinfo, nvseed } = data)

  let [seeds, patch_form] = init_data(data.nslist, data.nvseed)
  let prune = ''

  async function submit_patch() {
    const url = `/api/seeds/${nvinfo.id}/${nvseed.sname}/patch`
    const res = await api_call(url, 'PUT', patch_form, fetch)

    if (res.error) return alert(res.error)
    else clean_jump(res.pgidx)
  }

  let trunc_chidx = 1

  async function trunc_source() {
    const url = `/api/seeds/${nvinfo.id}/${nvseed.sname}/trunc`
    const res = await api_call(url, 'PUT', { chidx: trunc_chidx }, fetch)

    if (res.error) return alert(res.error)
    else clean_jump(res.pgidx)
  }

  async function prune_source() {
    const url = `/api/seeds/${nvinfo.id}/${nvseed.sname}`
    const res = await api_call(url, 'DELETE', null, fetch)

    if (res.error) return alert(res.error)
    else goto(`/-${nvinfo.bslug}/chaps/=base`)
  }

  function clean_jump(pgidx: number) {
    uncache('nslists', nvinfo.id)
    uncache('nvseeds', `${nvinfo.id}/${nvseed.sname}`)

    const root_href = `/-${nvinfo.bslug}/chaps`
    const page_href = root_href + '/' + nvseed.sname

    // invalidate(root_href)
    // invalidate(page_href)
    goto(pgidx > 1 ? `${page_href}?pg=${pgidx}` : page_href)
  }

  function change_mirror(mirror: CV.Chroot) {
    patch_form.o_sname = mirror.sname
    patch_form.chmax = mirror.chmax
  }

  interface PatchForm {
    chmin: number
    chmax: number
    o_sname: string
    i_chmin: number
  }

  // prettier-ignore
  function init_data(nslist: CV.Nslist, nvseed : CV.Chroot): [CV.Chroot[], PatchForm] {
    const sname = nvseed?.sname || '=base'
    let seeds = [...nslist.other, ...nslist.users].filter((x) => x)

    seeds = seeds.filter((x) => x.sname != sname)

    const { chmax, sname: o_sname } = seeds[0] || { chmax: 0, sname: '' }

    const form = { chmin: 1, i_chmin: 1, chmax: chmax, o_sname }
    return [seeds, form]
  }
</script>

<svelte:head>
  <title>Nguồn truyện: {nvseed.sname} - {nvinfo.btitle_vi} - Chivi</title>
</svelte:head>

<article class="article">
  <h2>Cài đặt nguồn truyện</h2>

  <details open>
    <summary>Sao chép từ nguồn khác</summary>

    <div class="form-group">
      <div class="form-field">
        <label for="mirror" class="form-label">Chọn nguồn</label>
        <select class="m-input" id="mirror" value={patch_form.o_sname}>
          {#each seeds as mirror}
            <option
              disabled={mirror.chmax == 0 || mirror.sname == nvseed.sname}
              value={mirror.sname}
              on:click={() => change_mirror(mirror)}
              >[{mirror.sname}] ({mirror.chmax} chương)</option>
          {/each}
        </select>
      </div>

      <div class="group">
        <div class="form-field">
          <label class="form-label" for="patch_chmin">Từ chương</label>
          <input
            type="number"
            id="patch_chmin"
            class="m-input"
            bind:value={patch_form.chmin}
            on:change={() => (patch_form.i_chmin = patch_form.chmin)} />
        </div>

        <div class="form-field">
          <label class="form-label" for="patch_chmax">Tới chương</label>
          <input
            type="number"
            id="patch_chmax"
            class="m-input"
            bind:value={patch_form.chmax} />
        </div>
      </div>

      <div class="group">
        <div class="form-field">
          <label class="form-label" for="patch_i_chmin">Vị trí mới</label>
          <input
            type="number"
            id="patch_i_chmin"
            class="m-input"
            bind:value={patch_form.i_chmin} />
        </div>

        <div class="form-field _button">
          <button
            type="button"
            class="m-btn _primary _fill"
            on:click={submit_patch}>
            <SIcon name="copy" />
            <span>Sao chép</span>
          </button>
        </div>
      </div>
    </div>
  </details>

  <details open>
    <summary>Xoá chương thừa</summary>
    <div class="form-group">
      <div class="form-field">
        <label class="form-label _inline" for="trunc_chidx"
          >Xoá các chương từ vị trí</label>

        <input
          type="number"
          id="trunc_chidx"
          class="m-input"
          min="1"
          max={nvseed.chmax}
          bind:value={trunc_chidx} />
      </div>
      <div class="form-field _button">
        <button
          type="button"
          class="m-btn _warning _fill"
          on:click={trunc_source}>
          <SIcon name="cut" />
          <span>Xoá chương</span>
        </button>
      </div>
    </div>
  </details>

  <details>
    <summary>Xoá danh sách</summary>
    <div class="form-group">
      <div class="form-field">
        <label class="form-label" for="prune"
          >Gõ vào <em>{nvseed.sname}</em> để đảm bảo</label>
        <input type="text" id="prune" class="m-input" bind:value={prune} />
      </div>

      <div class="form-field _button">
        <button
          type="button"
          class="m-btn _harmful _fill"
          on:click={prune_source}
          disabled={prune != nvseed.sname}>
          <SIcon name="trash" />
          <span>Xoá danh sách</span>
        </button>
      </div>
    </div>
  </details>
</article>

<style lang="scss">
  select {
    width: 12rem;
    height: 2.25rem;
  }

  .form-group {
    display: flex;
    gap: 0.75rem;

    flex-direction: column;

    @include bp-min(ts) {
      flex-direction: row;
      align-items: flex-end;
    }
  }

  .group {
    display: flex;
    gap: 0.75rem;
    // justify-content: space-around;
    align-items: flex-end;

    .form-field {
      margin-top: 0;
    }
  }

  h2 {
    margin-bottom: 1rem;
  }

  .m-input {
    height: 2.25rem;
    &[type='number'] {
      width: 4.5rem;
      text-align: center;
    }
  }

  details + details {
    margin-top: 1rem;
  }

  summary {
    font-weight: 500;
    // @include ftsize(lg);
  }
</style>
