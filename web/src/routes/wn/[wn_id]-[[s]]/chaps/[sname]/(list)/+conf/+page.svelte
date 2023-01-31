<script lang="ts">
  // import { page } from '$app/stores'
  import { goto } from '$app/navigation'

  import { api_call } from '$lib/api_call'
  import { SIcon } from '$gui'

  import type { PageData } from './$types'
  import ReadPrivi from './ReadPrivi.svelte'
  import Remotes from './Remotes.svelte'
  export let data: PageData

  $: ({ nvinfo, curr_seed } = data)

  let [bg_seeds, patch_form] = init_data(data.seed_list, data.curr_seed)
  let prune = ''

  async function submit_patch() {
    const url = `/_wn/seeds/${nvinfo.id}/${curr_seed.sname}/patch`
    const res = await api_call(url, patch_form, 'PUT')

    if (res.error) return alert(res.error)
    else clean_jump(res.pgidx)
  }

  let trunc_chidx = 1

  async function trunc_source() {
    const url = `/_wn/seeds/${nvinfo.id}/${curr_seed.sname}/trunc`
    const res = await api_call(url, { chidx: trunc_chidx }, 'PUT')

    if (res.error) return alert(res.error)
    else clean_jump(res.pgidx)
  }

  async function prune_source() {
    const url = `/_db/seeds/${nvinfo.id}/${curr_seed.sname}`
    const res = await api_call(url, {}, 'DELETE')

    if (res.error) return alert(res.error)
    else goto(`/-${nvinfo.bslug}/chaps/=base`)
  }

  function clean_jump(pgidx: number) {
    const root_href = `/-${nvinfo.bslug}/chaps`
    const page_href = root_href + '/' + curr_seed.sname

    // invalidate(root_href)
    // invalidate(page_href)
    goto(pgidx > 1 ? `${page_href}?pg=${pgidx}` : page_href)
  }

  function change_bg_seed(mirror: CV.Chroot) {
    patch_form.o_sname = mirror.sname
    patch_form.chmax = mirror.chmax
  }

  interface PatchForm {
    chmin: number
    chmax: number
    o_sname: string
    i_chmin: number
  }

  function init_data({ users = [], backs = [] }, nvseed: CV.Chroot) {
    let seeds = [...users, ...backs].filter((x) => x.sname != nvseed.sname)
    seeds = seeds.filter((x) => x.chmax > 0)

    const { chmax, sname: o_sname } = seeds[0] || { chmax: 0, sname: '' }
    const form = { chmin: 1, i_chmin: 1, chmax: chmax, o_sname }
    return [seeds, form] as [CV.Chroot[], PatchForm]
  }

  $: can_edit = check_privi(data.curr_seed, data.seed_data, data._user)

  const check_privi = ({ sname }, { edit_privi }, { uname, privi }) => {
    if (privi < edit_privi) return false
    if (privi > 3 || sname[0] != '@') return true
    return sname == '@' + uname
  }

  $: edit_url = `/_wn/seeds/${nvinfo.id}/${curr_seed.sname}`
  $: ztitle = `${nvinfo.btitle_zh} ${nvinfo.author_zh}`
</script>

<article class="article">
  <h2>Cài đặt nguồn truyện</h2>

  <details open>
    <summary>Quyền hạn tối thiểu để xem nội dung chương tiết</summary>
    <ReadPrivi
      {can_edit}
      {edit_url}
      seed_data={data.seed_data}
      bind:curr_seed={data.curr_seed} />
  </details>

  <details open>
    <summary>Liên kết tới nguồn ngoài:</summary>
    <Remotes {ztitle} {can_edit} {edit_url} bind:seed_data={data.seed_data} />
  </details>

  <details>
    <summary>Sao chép từ nguồn khác</summary>

    <div class="form-group">
      <div class="form-field">
        <label for="mirror" class="form-label">Chọn nguồn</label>
        <select class="m-input" id="mirror" value={patch_form.o_sname}>
          {#each bg_seeds as bg_seed}
            <option
              disabled={bg_seed.chmax == 0 || bg_seed.sname == curr_seed.sname}
              value={bg_seed.sname}
              on:click={() => change_bg_seed(bg_seed)}
              >[{bg_seed.sname}] ({bg_seed.chmax} chương)</option>
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

  <details>
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
          max={curr_seed.chmax}
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
          >Gõ vào <em>{curr_seed.sname}</em> để đảm bảo</label>
        <input type="text" id="prune" class="m-input" bind:value={prune} />
      </div>

      <div class="form-field _button">
        <button
          type="button"
          class="m-btn _harmful _fill"
          on:click={prune_source}
          disabled={prune != curr_seed.sname}>
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
    @include ftsize(lg);
    @include fgcolor(secd);
    @include hover {
      @include fgcolor(primary, 5);
    }
  }
</style>
