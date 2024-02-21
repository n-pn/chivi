<script lang="ts">
  import { goto } from '$app/navigation'

  import SIcon from '$gui/atoms/SIcon.svelte'
  import { api_call } from '$lib/api_call'
  import { _pgidx } from '$lib/kit_path'

  import { get_user } from '$lib/stores'
  const _user = get_user()

  import type { PageData } from './$types'
  export let data: PageData

  $: ({ crepo } = data)
  $: action = `/_rd/tsrepos/${crepo.sroot}`

  let slink = data.crepo.rm_slink || ''

  let cut_from = 1
  $: cut_upto = data.crepo.chmax

  const update_conf = async (cform: Record<string, any>) => {
    try {
      const { crepo } = await api_call(action, cform, 'PATCH')
      goto(`/ts/${crepo.sroot}?pg=${_pgidx(crepo.chmax)}`)
    } catch (ex) {
      alert(ex.body.message)
    }
  }

  const action_plock = {
    slink: [1, 1, 2],
    cut_chap: [2, 1, 3],
  }

  $: ({ privi, vu_id } = $_user)

  const cannot_do = (type: string) => {
    if (privi > 4) return false
    if (crepo.stype == 1 && crepo.owner != vu_id) return true
    return privi < action_plock[type][crepo.stype]
  }
</script>

<details open>
  <summary>Liên kết với nguồn nhúng ngoài</summary>

  <div class="field">
    <input
      class="m-input _sm"
      type="link"
      name="rm_slink"
      bind:value={slink}
      placeholder="Thêm nguồn mới" />

    <button
      class="m-btn _sm _primary _fill"
      disabled={!slink && cannot_do('slink')}
      on:click={() => update_conf({ slink })}>
      <SIcon name="send" />
      <span>Lưu</span>
      <SIcon name="privi-{action_plock.slink[crepo.stype]}" iset="icons" />
    </button>
  </div>
</details>

<details open>
  <summary>Cắt bỏ các chương thừa</summary>

  <div class="cutchap m-flex _cy">
    <label class="u-label" for="cut_from">Từ vị trí</label>
    <input
      id="cut_from"
      class="m-input _sm"
      type="number"
      min="1"
      max={cut_upto}
      bind:value={cut_from} />

    <label class="u-label" for="cut_upto">tới vị trí</label>
    <input
      id="cut_upto"
      class="m-input _sm"
      type="number"
      min={cut_from}
      max={crepo.chmax}
      disabled
      bind:value={cut_upto} />
    <button
      type="button"
      class="m-btn _warning _fill u-right"
      disabled={cannot_do('cut_chap')}
      on:click={() => update_conf({ cut_from, cut_upto })}>
      <SIcon name="cut" />
      <span>Cắt bỏ</span>
      <SIcon name="privi-{action_plock.cut_chap[crepo.stype]}" iset="icons" />
    </button>
  </div>

  <div class="explain u-fg-tert">
    Xóa bỏ nội dung các chương từ chương thứ {cut_from} tới chương thứ {cut_upto}. Hãy kiểm tra kỹ
    trước khi thực hiện hành động, vì hành động này không thể đảo ngược.
  </div>

  <div class="explain u-warn">
    Lưu ý: Hiện tại do hạn chế từ hệ thống, bạn chưa thể lựa chọn xóa một phần chương tiết, chỉ có
    thể xóa hết tới chương cuối cùng.
  </div>
</details>

<style lang="scss">
  details {
    @include border(--bd-soft, $loc: bottom);
    padding-top: 0.25rem;
    &:last-child {
      border: none;
      margin-bottom: 1rem;
    }
  }

  .field {
    @include flex-cy($gap: 0.5rem);
    margin-bottom: 0.75rem;
    input {
      flex: 1;
    }
  }

  // summary {
  //   font-weight: 500;
  //   // line-height: 2rem;
  //   @include ftsize(lg);
  //   @include fgcolor(secd);

  //   &:hover,
  //   details[open] & {
  //     @include fgcolor(primary, 5);
  //   }
  // }

  // .hints {
  //   line-height: 1rem;
  //   font-style: italic;
  //   margin: 0.5rem 0;
  //   @include ftsize(sm);
  //   @include fgcolor(tert);
  // }

  // .options {
  //   @include flex-cy($gap: 0.5rem);
  //   flex-wrap: wrap;
  //   margin-top: 0.75rem;
  // }

  // .radio {
  //   cursor: pointer;
  //   display: inline-flex;
  //   line-height: 1.5rem;
  //   padding: 0.25rem 0;
  //   // font-weight: 500;
  //   input {
  //     margin-right: 0.25rem;
  //   }
  // }

  .cutchap {
    gap: 0.5rem;

    label {
      font-weight: 500;
    }
    input {
      width: 5rem;
      text-align: center;
    }
  }

  .explain {
    margin-top: 0.75rem;
    font-style: italic;
    line-height: 1.25rem;
  }
</style>
