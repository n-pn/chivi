<script lang="ts" context="module">
  import type { Writable } from 'svelte/store'
  import { chap_path } from '$lib/kit_path'
  import { upsert_memo } from '$lib/common/rdmemo'

  import {
    rstate_labels,
    rstate_icons,
    rstate_colors,
  } from '$lib/consts/rd_states'

  const star_names = ['--', 'Mứt', 'Nhạt', 'Ổn', 'Khá', 'Đỉnh']

  function gen_quick_read({ chmax, sroot }, rmemo: CV.Rdmemo) {
    const ch_no = rmemo.lc_ch_no || 1
    const p_idx = rmemo.lc_p_idx || 1

    return {
      ch_href: chap_path(`/ts/${sroot}`, ch_no, { ...rmemo, p_idx }),
      ch_icon: ['player-play', 'player-skip-forward', 'pin'][rmemo.lc_mtype],
      ch_mute: chmax == 0,
    }
  }
</script>

<script lang="ts">
  import { SIcon, Gmenu } from '$gui'

  export let crepo: CV.Tsrepo
  export let rmemo: Writable<CV.Rdmemo>
  export let conf_path = `/ts/${crepo.sroot}/+conf`

  $: sroot = `/ts/${crepo.sroot}`
  $: ({ ch_href, ch_icon, ch_mute } = gen_quick_read(crepo, $rmemo))

  $: rstate = $rmemo.rd_state
  $: rstars = $rmemo.rd_stars

  function render_stars(stars: number) {
    let output = ''
    for (; stars; stars--) output += '⭐'
    return output
  }

  async function update_rstate(rstate: number) {
    // if ($_user.privi < -1) return

    $rmemo.rd_state = $rmemo.rd_state == rstate ? 0 : rstate
    $rmemo = await upsert_memo($rmemo, 'rstate')
  }

  async function update_rating(rstars: number) {
    // if ($_user.privi < -1) return

    $rmemo.rd_stars = $rmemo.rd_stars == rstars ? 0 : rstars
    $rmemo = await upsert_memo($rmemo, 'rating')
  }
</script>

<div class="rdmemo">
  <a class="m-btn _fill _primary" href={sroot}>
    <SIcon name="list" />
    <span>Chương tiết</span>
  </a>

  <a class="m-btn" class:_primary={!ch_mute} href={ch_href}>
    <SIcon name={ch_icon} />
  </a>

  <Gmenu class="navi-item" loc="bottom">
    <button class="m-btn _{rstate_colors[rstate]}" slot="trigger">
      <SIcon name={rstate_icons[rstate]} />
      <span class="u-show-ts">{rstate_labels[rstate]}</span>
    </button>

    <svelte:fragment slot="content">
      {#each rstate_labels as label, value}
        <button
          class="gmenu-item"
          class:_active={value == rstate}
          on:click={() => update_rstate(value)}>
          <SIcon name={rstate_icons[value]} />
          <span>{label}</span>
          {#if value == rstate}<SIcon name="check" class="u-right" />{/if}
        </button>
      {/each}
    </svelte:fragment>
  </Gmenu>

  <Gmenu class="action" loc="bottom">
    <button class="m-btn" class:_warning={rstars > 0} slot="trigger">
      <SIcon name="star" />
      {#if rstars > 0}<span>{rstars}</span>{/if}
    </button>

    <svelte:fragment slot="content">
      {#each [1, 2, 3, 4, 5] as value}
        <button
          class="gmenu-item"
          class:_active={value == rstars}
          on:click={() => update_rating(value)}>
          <span>{star_names[value]}</span>
          <span class="u-right">{render_stars(value)}</span></button>
      {/each}
    </svelte:fragment>
  </Gmenu>

  <Gmenu class="action" loc="bottom">
    <button class="m-btn" slot="trigger">
      <SIcon name="dots" />
    </button>

    <svelte:fragment slot="content">
      <a class="gmenu-item _success" href="{sroot}/+text">
        <SIcon name="upload" />
        <span>Đăng text gốc</span>
      </a>

      <a class="gmenu-item _harmful" href={conf_path}>
        <SIcon name="edit" />
        <span>Sửa thông tin</span>
      </a>

      <a class="gmenu-item" href="/mt/dicts/{crepo.pdict}" data-kbd="p">
        <SIcon name="package" />
        <span>Từ điển riêng</span>
      </a>
    </svelte:fragment>
  </Gmenu>
</div>

<style lang="scss">
  .rdmemo {
    @include flex-ca($gap: 0.5rem);
    margin: 0.75rem 0;
  }
</style>
